provider "kubernetes" {
  host = var.cluster_endpoint
  cluster_ca_certificate = var.ca_cert
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "${path.module}/cluster-authN.sh"
    args = [var.cluster_name, var.aws_region]
  }
}