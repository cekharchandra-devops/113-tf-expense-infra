module "web_alb" {
  source = "terraform-aws-modules/alb/aws"
  internal = false
  name    = local.resource_name
  vpc_id  = data.aws_ssm_parameter.vpc_id.value
  subnets = local.public_subnet_ids
  create_security_group = false
  security_groups = [data.aws_ssm_parameter.web_alb_sg_id.value]
  enable_deletion_protection = false
  tags = merge(
    var.common_tags,
    var.web_alb_sg_tags,
    {
      Name = local.resource_name
    }   
  )
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = module.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "content is loaded from WEB ALB"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_ssm_parameter.certificate_arn.value

  default_action {
   type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "content is loaded from WEB ALB HTTPS"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.domain_name

  records = [
    {
      name    = "expense-${var.environment}"
      type    = "A"
      alias   = {
        name    = module.web_alb.dns_name
        zone_id = module.web_alb.zone_id
      }
      allow_overwrite = true
    }
  ]

}

