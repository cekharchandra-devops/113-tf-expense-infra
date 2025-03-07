module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name
  ami = data.aws_ami.joindevops.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  subnet_id              = local.private_subnet_id
  
  tags = merge(
    var.common_tags,
    var.backend_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "null_resource" "backend" {
  triggers = {
     instance_id =   module.backend.id
  }

  connection {
    host = module.backend.private_ip
    user = "ec2-user"
    password = "DevOps321"
    type = "ssh"
  }

  provisioner "file" {
    source = "${var.backend_tags.Component}.sh"
    destination = "/tmp/backend.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/backend.sh",
      "sudo sh /tmp/backend.sh ${var.environment} ${var.backend_tags.Component}"
     ]
  }
  depends_on = [ module.backend ]
}

resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state = "stopped"
  depends_on = [ null_resource.backend ]
}

resource "aws_ami_from_instance" "backend" {
  name = local.resource_name
  source_instance_id = module.backend.id
  depends_on = [ aws_ec2_instance_state.backend ]
}

resource "null_resource" "backend_delete" {
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
  }
  depends_on = [ aws_ami_from_instance.backend ]
}

resource "aws_launch_template" "backend" {
  name = local.resource_name

  image_id = aws_ami_from_instance.backend.id

  instance_initiated_shutdown_behavior = "terminate"

  update_default_version = true

  instance_type = "t3.micro"

  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }

}

resource "aws_lb_target_group" "backend" {
  name     = local.resource_name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    healthy_threshold = 2
    interval = 120
    matcher = "200-299"
    path = "/health"
    port = 8080
    protocol = "HTTP"
    timeout = 110
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "backend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2 
  target_group_arns = [aws_lb_target_group.backend.arn]
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  
  vpc_zone_identifier       = [local.private_subnet_id]

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

resource "aws_autoscaling_policy" "backend" {
  name                   = local.resource_name
  autoscaling_group_name = aws_autoscaling_group.backend.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = 75
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.aws_lb_listener_arn.value
  priority     = 100 # low priority will be evaluated first

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["${var.backend_tags.Component}.app-${var.environment}.${var.zone_name}"]
    }
  }
}