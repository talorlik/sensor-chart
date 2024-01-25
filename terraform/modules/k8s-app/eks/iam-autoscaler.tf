data "aws_iam_policy_document" "eks_cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler", "system:serviceaccount:mtr-namespace:mtr-serviceaccount", "system:serviceaccount:kube-system:aws_load_balancer_controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_cluster_autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_autoscaler_assume_role_policy.json
  name               = var.aws_iam
}
resource "aws_iam_policy" "eks_cluster_autoscaler" {
  policy = file("../../../modules/k8s-app/eks/iam-autoscaling-policy.json")
  name   = "${var.aws_iam}-autoscaling"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  policy = file("../../../modules/k8s-app/eks/aws-load-balancer-controller.json")
  name   = "${var.aws_iam}-load-balancer"
}

resource "aws_iam_policy" "production_sts" {
  policy = file("../../../modules/k8s-app/eks/Production-sts.json")
  name   = "${var.aws_iam}-production_sts"
}


resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_attach" {
  role       = aws_iam_role.eks_cluster_autoscaler.name
  policy_arn = aws_iam_policy.eks_cluster_autoscaler.arn
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.eks_cluster_autoscaler.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

resource "aws_iam_role_policy_attachment" "production_sts" {
  role       = aws_iam_role.eks_cluster_autoscaler.name
  policy_arn = aws_iam_policy.production_sts.arn
}

output "eks_cluster_autoscaler_arn" {
  value = aws_iam_role.eks_cluster_autoscaler.arn
}
