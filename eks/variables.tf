variable eks_cluster_name {
  type = string
  description = "The name of the eks cluster which should have been pre-provisioned."
}

variable aws_region {
  type = string
  default = "eu-west-1"
}