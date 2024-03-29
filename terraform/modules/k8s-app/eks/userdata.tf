locals {
  eks-node-private-userdata = <<USERDATA
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="
--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash -xe
sudo /etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.main.endpoint}' --b64-cluster-ca '${aws_eks_cluster.main.certificate_authority[0].data}' '${aws_eks_cluster.main.name}'
echo "Running custom user data script" > /tmp/me.txt
yum install -y amazon-ssm-sensor
echo "yum'd sensor" >> /tmp/me.txt
yum update -y
systemctl enable amazon-ssm-sensor && systemctl start amazon-ssm-sensor
date >> /tmp/me.txt
--==MYBOUNDARY==--
USERDATA
}