variable "zone_name" {
  default = "devsecmlops.online"
}

variable "zone_id" {
  default = "Z081461419PCT70J0BCQ6"
}

variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
  }
}