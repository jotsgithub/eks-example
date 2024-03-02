#variable lt_name {
#  type        = string
#  description = <<DESC
#The postfix of the launch template name which is to be appended to the cluster name to derive the final launch
#template name
#DESC
#}

variable eks_cluster_name {
  type = string
  description = "The name of the eks cluster which should have been pre-provisioned."
}

variable aws_region {
  type = string
  default = "eu-west-1"
}

variable "cluster_endpoint" {
  type = string
  default = "https://43B8FA018503EB203DDE9336831CF925.yl4.eu-west-1.eks.amazonaws.com"
}

#variable instance_type {
#  type = string
#}
#
#variable "node_labels" {
#  type = map(any)
#  default = {}
#}
#
#variable "ssh_key_name" {
#  type = string
#  default = "i765006-temp-key"
#}

variable "worker_node_az" {
  type = list(string)
  default = []
}