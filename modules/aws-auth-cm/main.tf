resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<-EOT
      - rolearn: ${var.node_role_arn}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
      - rolearn: ${var.lambda_role_arn}
        username: lightswitch-lambda
        groups:
          - system:masters
      - rolearn: ${var.lambda_role_arn}
        username: lightswitch-lambda
        groups:
          - system:masters
    EOT
  }
}