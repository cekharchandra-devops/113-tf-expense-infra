module "alb" {
  source = "terraform-aws-modules/alb/aws"
  internal = true
  name    = local.resource_name
  vpc_id  = data.aws_ssm_parameter.vpc_id.value
  subnets = local.private_subnet_ids
  create_security_group = false
  security_groups = [data.aws_ssm_parameter.app_alb_sg_id.value]
  enable_deletion_protection = false
  tags = merge(
    var.common_tags,
    var.app_alb_sg_tags,
    {
      Name = local.resource_name
    }   
  )
}

resource "aws_lb_listener" "app_alb_listener" {
  load_balancer_arn = module.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "content is loaded from APP ALB"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.domain_name

  records = [
    {
      name    = "*.app-${var.environment}"
      type    = "A"
      alias   = {
        name    = module.alb.dns_name
        zone_id = module.alb.zone_id
      }
      allow_overwrite = true
    }
  ]

}

