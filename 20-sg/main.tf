module "mysql" {
    source = "git::https://github.com/cekharchandra-devops/110-terrraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "mysql"
    sg_tags = var.mysql_sg_tags
}

module "frontend" {
    source = "git::https://github.com/cekharchandra-devops/110-terrraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "frontend"
    sg_tags = var.frontend_sg_tags
}

module "backend" {
    source = "git::https://github.com/cekharchandra-devops/110-terrraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "backend"
    sg_tags = var.backend_sg_tags
}

module "ansible" {
    source = "git::https://github.com/cekharchandra-devops/110-terrraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "ansible"
    sg_tags = var.ansible_sg_tags
}

module "bastion" {
    source = "git::https://github.com/cekharchandra-devops/110-terrraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "bastion"
    sg_tags = var.bastion_sg_tags
}

module "app_alb" {
    source = "git::https://github.com/cekharchandra-devops/110-terrraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "app-alb"
    sg_tags = var.app_alb_sg_tags
}

module "web_alb" {
    source = "git::https://github.com/cekharchandra-devops/110-terrraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "web-alb"
    sg_tags = var.web_alb_sg_tags
}
module "vpn" {
    source = "git::https://github.com/cekharchandra-devops/110-terrraform-aws-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    sg_name = "vpn"
    sg_tags = var.vpn_sg_tags
}

resource "aws_security_group_rule" "mysql_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend.sg_id
  security_group_id = module.mysql.sg_id
}

# resource "aws_security_group_rule" "backend_frontend" {
#   type              = "ingress"
#   from_port         = 8080
#   to_port           = 8080
#   protocol          = "tcp"
#   source_security_group_id = module.frontend.sg_id
#   security_group_id = module.backend.sg_id
# }

# resource "aws_security_group_rule" "frontend_public" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = module.frontend.sg_id
# }

# bastion

resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_bastion_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb.sg_id
  security_group_id = module.backend.sg_id
}


resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.mysql.sg_id
}

# ansible

resource "aws_security_group_rule" "ansible_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ansible.sg_id
}

resource "aws_security_group_rule" "frontend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "backend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible.sg_id
  security_group_id = module.backend.sg_id
}

# resource "aws_security_group_rule" "mysql_ansible" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   source_security_group_id = module.ansible.sg_id
#   security_group_id = module.mysql.sg_id
# }

resource "aws_security_group_rule" "app_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.app_alb.sg_id
}

resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.app_alb.sg_id
}

resource "aws_security_group_rule" "backend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_vpn_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "database_vpn" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.mysql.sg_id
}

resource "aws_security_group_rule" "vpn_public_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_public_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_public_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "web_alb_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = module.web_alb.sg_id
}

resource "aws_security_group_rule" "web_alb_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = module.web_alb.sg_id
}

resource "aws_security_group_rule" "frontend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_web_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_alb.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "app_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.frontend.sg_id
  security_group_id = module.app_alb.sg_id
}