resource "aws_ssm_parameter" "aws_lb_listener_arn" {
  name = "/${var.project_name}/${var.environment}/aws_lb_listener_arn"
  type = "String"
  value = aws_lb_listener.app_alb_listener.arn
}