data aws_partition "current" {}

data aws_vpc "spoke-vpc" {
  filter {
    name   = "tag:Name"
    values = ["main"]
  }
}

data aws_subnets "public-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spoke-vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["Public*"]
  }
}

data aws_iam_role "cluster-role" {
  name = "eksctl-crossplane-poc-cluster-ServiceRole-MFRBIYZM6IG"
}

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

locals {
  worker_node_role_name = "AmazonEKSNodeRole"
}

data "aws_iam_role" "worker_node_role" {
  name = local.worker_node_role_name
}


data aws_subnets "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spoke-vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["Private*"]
  }
}