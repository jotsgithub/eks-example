data aws_eks_cluster "this" {
  name = var.eks_cluster_name
}

data aws_eks_cluster_auth "this" {
  name = var.eks_cluster_name
}
// TODO: check if missing a permission here
data aws_iam_instance_profile "worker_node_instance_profile" {
  name = local.worker_node_instance_profile_name
}

// Instance profile and the underlying IAM role have the same name
locals {
  worker_node_instance_profile_name = "AmazonEKSNodeRole"
}

data "aws_iam_role" "worker_node_role" {
  name = local.worker_node_instance_profile_name
}