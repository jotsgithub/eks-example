#locals {
#  capacity_type = ["on-demand"]
#  allowed_instance_types = [
#    "m5.xlarge",
#    "m5.2xlarge",
#    "c5.large",
#    "c5.xlarge",
#    "c5.2xlarge",
#    "m5.large",
#  ]
#  allowed_instance_type_java = [
#    "m5.large",
#    "m5.xlarge",
#    "m5.2xlarge",
#    "m5.4xlarge",
#  ]
#  allowed_instance_type_golang = [
#    "c5.large",
#    "c5.xlarge",
#    "c5.2xlarge"
#  ]
#}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    annotations = {
      name = "karpenter"
    }
    name = "karpenter"
  }
}

# Configure the OIDC-backed identity provider to allow the Karpenter
# ServiceAccount to assume the role. This will actually create the role
# for us too.
module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${var.eks_cluster_name}-${var.aws_region}"
  provider_url                  = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.karpenter.id}:karpenter"]
}

resource "aws_iam_role_policy" "karpenter_contoller" {
  name = "karpenter-policy"
  role = module.iam_assumable_role_karpenter.iam_role_name
  policy = file("karpenter-iam.json")
}

data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
#  role       = module.eks.worker_iam_role_name
  role = data.aws_iam_role.worker_node_role.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}

#resource "aws_iam_instance_profile" "karpenter" {
#  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
#  role = module.eks.worker_iam_role_name
#}

resource "helm_release" "karpenter" {
  namespace = kubernetes_namespace.karpenter.id

  name       = "karpenter"
#  repository = "https://charts.karpenter.sh"
#  repository = "oci://public.ecr.aws/karpenter/karpenter"
  chart      = "oci://public.ecr.aws/karpenter/karpenter"
  version    = "v0.31.0"
#  version    = "0.16.3"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_karpenter.iam_role_arn
  }

  set {
    name  = "settings.aws.clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "setting.clusterEndpoint"
    value = data.aws_eks_cluster.this.endpoint
  }
  set {
    name  = "settings.aws.defaultInstanceProfile"
#    value = aws_iam_instance_profile.karpenter.name
    value = data.aws_iam_instance_profile.worker_node_instance_profile.name
  }
}

data "kubectl_path_documents" "provisioner_manifests" {
  pattern = "./karpenter-provisioner-manifests/*.yaml"
  vars = {
    cluster_name = var.eks_cluster_name
  }
}

resource "kubectl_manifest" "provisioners" {
  for_each  = data.kubectl_path_documents.provisioner_manifests.manifests
  yaml_body = each.value
}