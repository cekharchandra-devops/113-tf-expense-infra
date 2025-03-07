variable "project_name" {
  type = string
  default = "expense"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "Expense"
    Environment = "dev"
    terraform = "true"
  }
}

variable "app_alb_sg_tags" {
  default = {
    Component = "app-alb"
  }
  
}

variable "domain_name" {
  type = string
  default = "devsecmlops.online"
  
}