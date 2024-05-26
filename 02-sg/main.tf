module "db" {
  source="../../terraform-aws-security"
  project_name = var.project_name
  environment = var.environment 
  sg_description = "security group for DB MySQL instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "db"
  common_tags = var.common_tags
}

module "backend" {
  source="../../terraform-aws-security"
  project_name = var.project_name
  environment = var.environment 
  sg_description = "security group for backend instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "backend"
  common_tags = var.common_tags
}

module "frontend" {
  source="../../terraform-aws-security"
  project_name = var.project_name
  environment = var.environment 
  sg_description = "security group for frontend instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "frontend"
  common_tags = var.common_tags
}

#Bastion
module "bastion" {
  source="../../terraform-aws-security"
  project_name = var.project_name
  environment = var.environment 
  sg_description = "security group for bastion instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "bastion"
  common_tags = var.common_tags
}

#Ansible
module "ansible" {
  source="../../terraform-aws-security"
  project_name = var.project_name
  environment = var.environment 
  sg_description = "security group for ansible instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "ansible"
  common_tags = var.common_tags
}


#RULES:
#DB is accepting connections from backend.
resource "aws_security_group_rule" "db_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend.sg_id
  security_group_id = module.db.sg_id
}

#DB is accepting connections from bastion.
resource "aws_security_group_rule" "db_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.db.sg_id
}

#backend
resource "aws_security_group_rule" "backend_frontend" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.frontend.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible.sg_id
  security_group_id = module.backend.sg_id
}



#frontend

resource "aws_security_group_rule" "frontend_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible.sg_id
  security_group_id = module.frontend.sg_id
}

#Bastion
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

#Ansible
resource "aws_security_group_rule" "ansible_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.ansible.sg_id
}

