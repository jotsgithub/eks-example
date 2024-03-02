locals {
  ls_lambda_role_name = "${var.eks_cluster_name}-${var.aws_region}-lightswitch-lambda-role"
}

resource "aws_iam_role" "ls_lambda_role" {
  name               = local.ls_lambda_role_name
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "ls_lambda_policy" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
    ]
    effect = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect   = "Allow"
    resources = ["arn:aws:logs:*:*"]
  }
}

#resource "aws_cloudwatch_log_group" "function_log_group" {
#  name              = "/aws/lambda/${aws_lambda_function.lightswitch_lambda.function_name}"
#  retention_in_days = 7
#  lifecycle {
#    prevent_destroy = false
#  }
#}

resource "aws_iam_role_policy" "ls_lambda_role_policy" {
  policy = data.aws_iam_policy_document.ls_lambda_policy.json
  role   = aws_iam_role.ls_lambda_role.id
  name   = local.ls_lambda_role_name
}

resource "aws_security_group" "lambda_security_group" {
  name = "lambda_security_group"
  description = "security groups for lambdas"
  vpc_id = data.aws_vpc.spoke-vpc.id
}

resource "aws_security_group_rule" "lambda_allow_egress_to_eks" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_security_group.id
  to_port           = 443
  type              = "egress"
  source_security_group_id = aws_security_group.control_plane_sg.id
}

resource aws_lambda_function "lightswitch_lambda" {
  filename         = data.archive_file.lambda_source.output_path
  function_name    = "eks-lightswitch-lambda"
  role             = aws_iam_role.ls_lambda_role.arn
  handler          = "eks-lightswitch"
  runtime          = "go1.x"
  source_code_hash = filebase64sha256(data.archive_file.lambda_source.output_path)
  vpc_config {
    security_group_ids = [aws_security_group.lambda_security_group.id]
    subnet_ids         = data.aws_subnets.private_subnets.ids
  }
}

data archive_file "lambda_source" {
  type        = "zip"
  source_dir  = "../lambda_functions/eks-lightswitch"
  output_path = "../lambda_functions/archives/lightswitch.zip"
  excludes    = ["go.mod", "main.go", "go.sum", "vendor", "pkg", "cmd", "internal"]
}

#resource "aws_lambda_invocation" "lightswitch" {
#  function_name = aws_lambda_function.lightswitch_lambda.function_name
#  lifecycle_scope = "CRUD"
#  input         = jsonencode({
#    reason = "to force lambda trigger"
#    clusterName = var.eks_cluster_name
#    clusterEndpoint = aws_eks_cluster.test-eks-cluster.endpoint
#    clusterCA = aws_eks_cluster.test-eks-cluster.certificate_authority[0].data
#  })
#}
