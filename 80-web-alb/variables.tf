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

variable "web_alb_sg_tags" {
  default = {
    Component = "web-alb"
  }
  
}

variable "domain_name" {
  type = string
  default = "devsecmlops.online"
  
}