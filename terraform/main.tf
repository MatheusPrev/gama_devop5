provider "aws" {
  region = "us-east-1"
}

module "criar_vpc" {
  source = "./VPC"
}

module "criar_instancia" {
  source = "./instancia"
  subnet_id = module.criar_vpc.subnet_id
  vpc_id = module.criar_vpc.vpc_id
}
