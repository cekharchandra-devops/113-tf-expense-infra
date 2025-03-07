module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name
  ami = data.aws_ami.joindevops.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  subnet_id              = local.public_subnet_id
  
  tags = merge(
    var.common_tags,
    var.frontend_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "null_resource" "frontend" {
  triggers = {
     instance_id =   module.frontend.id
  }

  connection {
    host = module.frontend.private_ip
    user = "ec2-user"
    password = "DevOps321"
    type = "ssh"
  }

  provisioner "file" {
    source = "${var.frontend_tags.Component}.sh"
    destination = "/tmp/frontend.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/frontend.sh",
      "sudo sh /tmp/frontend.sh ${var.environment} ${var.frontend_tags.Component}"
     ]
  }
  depends_on = [ module.frontend ]
}

resource "aws_ec2_instance_state" "frontend" {
  instance_id = module.frontend.id
  state = "stopped"
  depends_on = [ null_resource.frontend ]
}

resource "aws_ami_from_instance" "frontend" {
  name = local.resource_name
  source_instance_id = module.frontend.id
  depends_on = [ aws_ec2_instance_state.frontend ]
}

resource "null_resource" "frontend_delete" {
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.frontend.id}"
  }
  depends_on = [ aws_ami_from_instance.frontend ]
}

resource "aws_launch_template" "frontend" {
  name = local.resource_name

  image_id = aws_ami_from_instance.frontend.id

  instance_initiated_shutdown_behavior = "terminate"

  update_default_version = true

  instance_type = "t3.micro"

  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }

}

resource "aws_lb_target_group" "frontend" {
  name     = local.resource_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    healthy_threshold = 2
    interval = 120
    matcher = "200-299"
    path = "/health"
    port = 80
    protocol = "HTTP"
    timeout = 110
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "frontend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2 
  target_group_arns = [aws_lb_target_group.frontend.arn]
  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }
  
  vpc_zone_identifier       = [local.public_subnet_id]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "Expense"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "frontend" {
  name                   = local.resource_name
  autoscaling_group_name = aws_autoscaling_group.frontend.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = 75
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = data.aws_ssm_parameter.web_alb_listener_arn.value
  priority     = 100 # low priority will be evaluated first

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["${var.project_name}-${var.environment}.${var.zone_name}"]
    }
  }
}