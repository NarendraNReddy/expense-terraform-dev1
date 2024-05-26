locals {
  public_subnet_id=element(split(",",data.aws_ssm_parameter.public_subnet_ids.value),0)
}

 #connecting stringlist to list and get first element
  #split(separator, string)
  #Get element