#General vars
region      = "eu-west-2"
prefix      = "k8s-attack-techniques"
project     = "k8s-attack-techniques"
application = "k8s-attack-techniques"

#VPC
create_vpc          = true
cidr_block          = "10.0.24.0/21"
azs                 = ["eu-west-2c", "eu-west-2b", "eu-west-2a", "eu-west-2c", "eu-west-2b"]
public_subnet_cidr  = ["10.0.24.128/25", "10.0.25.0/25", "10.0.25.128/25"]
private_subnet_cidr = ["10.0.27.0/24", "10.0.28.0/24", "10.0.29.0/24", "10.0.30.0/24"]
extra_subnet_cidr   = ["10.0.26.0/24"]
enable_nat_gateway  = true
public_eks_tag      = { "kubernetes.io/role/elb" = 1 }
private_eks_tag     = { "kubernetes.io/role/internal-elb" = 1 }
eks_cluster_name    = "k8s-attack-techniques"

#EKS
cluster_name            = "k8s-attack-techniques"
k8s_version             = "1.23"
node_instance_type      = "t3.medium"
aws_iam                 = "eks-k8s-attack-techniques"
desired_capacity        = 1
max_size                = 5
min_size                = 0
max_unavailable         = 1
endpoint_private_access = true
endpoint_public_access  = true
eks_cw_logging          = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
