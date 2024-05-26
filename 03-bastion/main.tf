module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-bastion"
  ami=  data.aws_ami.ami_info.id

  instance_type          = "t3.micro"
  
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  #connecting stringlist to list and get first element
  #split(separator, string)
  #Get element
  subnet_id              = local.public_subnet_id

  tags = merge(
    var.common_tags,
    {
      Name="${var.project_name}-${var.environment}-bastion"
    }
  )
}

