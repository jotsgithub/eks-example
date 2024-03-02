resource aws_eks_cluster "test-eks-cluster" {
  name     = var.eks_cluster_name
  role_arn = data.aws_iam_role.cluster-role.arn
  vpc_config {
    subnet_ids = data.aws_subnets.public-subnets.ids
    security_group_ids = [aws_security_group.control_plane_sg.id]
    endpoint_private_access = true
    endpoint_public_access = true
  }
  version = "1.25"
  enabled_cluster_log_types = [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"]
}
