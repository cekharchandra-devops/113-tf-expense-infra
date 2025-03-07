locals {
  resource_name = "${var.project_name}-${var.environment}-web-alb"
  public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
}