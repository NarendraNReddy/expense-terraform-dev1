module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-backend"
  ami=  data.aws_ami.ami_info.id

  instance_type          = "t3.micro"
  
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  #connecting stringlist to list and get first element
  #split(separator, string)
  #Get element
  subnet_id              = local.private_subnet_id

  tags = merge(
    var.common_tags,
    {
      Name="${var.project_name}-${var.environment}-backend"
    }
  )
}

module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-frontend"
  ami=  data.aws_ami.ami_info.id

  instance_type          = "t3.micro"
  
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  #connecting stringlist to list and get first element
  #split(separator, string)
  #Get element
  subnet_id              = local.public_subnet_id

  tags = merge(
    var.common_tags,
    {
      Name="${var.project_name}-${var.environment}-frontend"
    }
  )
}

module "ansible" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-ansible"
  ami=  data.aws_ami.ami_info.id
 

  instance_type          = "t3.micro"
  user_data = file("expense.sh")
  
  vpc_security_group_ids = [data.aws_ssm_parameter.ansible_sg_id.value]
  #connecting stringlist to list and get first element
  #split(separator, string)
  #Get element
  subnet_id              = local.public_subnet_id
  

  tags = merge(
    var.common_tags,
    {
      Name="${var.project_name}-${var.environment}-ansible"
    }
  )
  depends_on = [ module.backend,module.frontend ]
}

#R53 records:
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "backend"
      type    = "A"
      ttl     = 1
      records = [
        module.backend.private_ip
      ]
      
    },
    {
      name    = "frontend"
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.private_ip
      ]
    },
        {
      name    = ""#narendra.shop
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.public_ip
      ]
    },
  ]

  
}



