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
variable "bastion_tags" {
  default = {
    Component = "bastion"
  }
  
}