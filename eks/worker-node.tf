resource "aws_iam_instance_profile" "worker_node_instance_profile" {
  name = local.worker_node_role_name
  role = data.aws_iam_role.worker_node_role.name
}

module "aws-auth-cm" {
  source = "../modules/aws-auth-cm"
  node_role_arn = data.aws_iam_role.worker_node_role.arn
  lambda_role_arn = aws_iam_role.ls_lambda_role.arn
  cluster_endpoint = aws_eks_cluster.test-eks-cluster.endpoint
  ca_cert = base64decode(aws_eks_cluster.test-eks-cluster.certificate_authority[0].data)
  cluster_name = aws_eks_cluster.test-eks-cluster.name
  aws_region = var.aws_region
}