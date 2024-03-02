resource "aws_security_group" "control_plane_sg" {
  vpc_id = data.aws_vpc.spoke-vpc.id
  name = "${var.eks_cluster_name}-control-plane-sg"
}

resource aws_security_group "worker_node_sg" {
  vpc_id = data.aws_vpc.spoke-vpc.id
  name = "${var.eks_cluster_name}-worker-node-sg"
}

#######################################################################################################
# Control plane SG Rules
#######################################################################################################
resource "aws_security_group_rule" "control-plane-egress-to-workers-10250" {
  from_port         = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.control_plane_sg.id
  to_port           = 10250
  type              = "egress"
  source_security_group_id = aws_security_group.worker_node_sg.id
}

resource "aws_security_group_rule" "control-plane-ingress-from-workers-443" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.control_plane_sg.id
  to_port           = 443
  type              = "ingress"
  source_security_group_id = aws_security_group.worker_node_sg.id
}

resource "aws_security_group_rule" "control-plane-ingress-from-workers-6443" {
  from_port         = 6443
  protocol          = "tcp"
  security_group_id = aws_security_group.control_plane_sg.id
  to_port           = 6443
  type              = "ingress"
  source_security_group_id = aws_security_group.worker_node_sg.id
}

resource "aws_security_group_rule" "control-plane-ingress-from-lambda-443" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.control_plane_sg.id
  to_port           = 443
  type              = "ingress"
  source_security_group_id = aws_security_group.lambda_security_group.id
}

#######################################################################################################
# Worker Node SG Rules
#######################################################################################################
resource "aws_security_group_rule" "worker-node-ingress-from-control-plane-10250" {
  from_port         = 10250
  protocol          = "tcp"
  security_group_id = aws_security_group.worker_node_sg.id
  to_port           = 10250
  type              = "ingress"
  source_security_group_id = aws_security_group.control_plane_sg.id
}

resource "aws_security_group_rule" "worker-node-ingress-from-control-plane-karpenter" {
  from_port         = 8443
  protocol          = "tcp"
  security_group_id = aws_security_group.worker_node_sg.id
  to_port           = 8443
  type              = "ingress"
  source_security_group_id = aws_security_group.control_plane_sg.id
}

resource "aws_security_group_rule" "worker-to-worker-node-ingress-all-ports" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.worker_node_sg.id
  to_port           = 0
  type              = "ingress"
  source_security_group_id = aws_security_group.worker_node_sg.id
}

resource "aws_security_group_rule" "worker-node-to-control-plane-egress-443" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.worker_node_sg.id
  to_port           = 443
  type              = "egress"
  source_security_group_id = aws_security_group.control_plane_sg.id
}


resource "aws_security_group_rule" "worker-egress-all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.worker_node_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

# Temporary SG to be able to do ssh on worker node
resource aws_security_group_rule "work_node_ssh" {
  protocol          = "tcp"
  security_group_id = aws_security_group.worker_node_sg.id
  to_port           = 22
  from_port         = 22
  type              = "ingress"
  cidr_blocks = ["${data.external.myipaddr.result.ip}/32"]
}
