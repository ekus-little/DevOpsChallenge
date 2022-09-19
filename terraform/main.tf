vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]

      labels = {
        type = "server"
      }
    

    two = {
      name = "node-group-2"

      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      pre_bootstrap_user_data = <<-EOT
      echo 'foo bar'
      EOT

      vpc_security_group_ids = [
        aws_security_group.node_group_two.id
      ]

      labels = {
        type = "client"
      }
    }
  variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }

  required_version = "~> 1.2.0"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "challenge-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}
   
