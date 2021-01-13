#--------------------------------------------------------
# Create a new VPC with public and private subnets on 2 Azs
#--------------------------------------------------------
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-${var.app_name}-${var.environment}"
  cidr = var.cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = var.environment
    Application = var.app_name
    Owner = var.owner
  }
}