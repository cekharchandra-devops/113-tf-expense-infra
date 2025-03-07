variable "project_name" {
  type = string
  default = "expense"
  
}

variable "environment" {
  type = string
  default = "dev"
  
}

variable "common_tags" {
  type = map(string)
  default = {
    "project" = "Expense"
    "environment" = "Dev"
    "Terraform" = "true"
  }
  
}

variable "mysql_sg_tags" {
  default = {
    Component = "mysql"
  }
}

variable "frontend_sg_tags" {
  default = {
    Component = "frontend"
  }
  
}

variable "backend_sg_tags" {
  default = {
    Component = "backend"
  }
  
}

variable "ansible_sg_tags" {
  default = {
    Component = "ansible"
  }
  
}

variable "bastion_sg_tags" {
  default = {
    Component = "bastion"
  }
  
}

variable "app_alb_sg_tags" {
  default = {
    Component = "app-alb"
  }
  
}

variable "vpn_sg_tags" {
  default = {
    Component = "vpn"
  }
}

variable "web_alb_sg_tags" {
  default = {
    Component = "web-alb"
  }
}