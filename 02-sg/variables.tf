variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
default = {
    Project="expense"
    Environment="dev"
    Terraform=true
}
}


# variable "sg_name" {
#   type=string
# }



# variable "vpc_id" {
#   type=string #user can provide values
  
# }


