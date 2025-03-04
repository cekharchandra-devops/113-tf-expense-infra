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
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
  }
}

variable "public_cidr_block" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  
}

variable "private_cidr_block" {
  type = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
  
}

variable "database_cidr_block" {
  type = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24"]
  
}