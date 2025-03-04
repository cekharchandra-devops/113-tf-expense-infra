resource "aws_ssm_parameter" "frontend_sg_id" {
  name = "/${var.project_name}/${var.environment}/frontend_sg_id"
  type = "String"
  value = module.frontend.sg_id
}
resource "aws_ssm_parameter" "backend_sg_id" {
  name = "/${var.project_name}/${var.environment}/backend_sg_id"
  type = "String"
  value = module.backend.sg_id
}
resource "aws_ssm_parameter" "mysql_sg_id" {
  name = "/${var.project_name}/${var.environment}/mysql_sg_id"
  type = "String"
  value = module.mysql.sg_id
}
resource "aws_ssm_parameter" "ansible_sg_id" {
  name = "/${var.project_name}/${var.environment}/ansible_sg_id"
  type = "String"
  value = module.ansible.sg_id
}
resource "aws_ssm_parameter" "bastion_sg_id" {
  name = "/${var.project_name}/${var.environment}/bastion_sg_id"
  type = "String"
  value = module.bastion.sg_id
}
