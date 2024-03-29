locals {
  common_tags = {
    Environment = terraform.workspace
    Project     = "${var.project}"
    Application = "${var.application}"
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "cluster-sg" {
  tags = merge(
    tomap({ "Name" = "${var.prefix}-cl-sg" }),
    local.common_tags
  )
  vpc_id      = var.vpc_id
  description = "intra cluster traffic"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "cluster-sg-ingress-rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  cidr_blocks       = ["10.0.16.0/21"]
  security_group_id = aws_security_group.cluster-sg.id
}
resource "aws_security_group_rule" "cluster-sg-egress-rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster-sg.id
}
#####################################################################
##### security groups for EKS    ######################
#####################################################################
