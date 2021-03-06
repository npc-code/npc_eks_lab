# Nodes in private subnets
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.test_cluster.name
  version         = aws_eks_cluster.test_cluster.version
  node_group_name = "${var.cluster_name}-node-group-main-${var.environment}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.network.private_subnets


  #ami_type        = var.ami_type
  #disk_size       = var.disk_size
  #instance_types  = var.instance_types

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }

  tags = {
    Name = "${var.cluster_name}-node-group-main-${var.environment}"
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only,
    aws_eks_cluster.test_cluster
  ]
}

#node group with launch template test
resource "aws_eks_node_group" "custom" {
  cluster_name    = aws_eks_cluster.test_cluster.name
  node_group_name = "${var.cluster_name}-node-group-custom-${var.environment}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.network.private_subnets

  #ami_type        = var.ami_type
  #disk_size       = var.disk_size
  #instance_types  = var.instance_types

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }


  launch_template {
    name    = aws_launch_template.test_launch_template.name
    version = aws_launch_template.test_launch_template.latest_version
  }

  tags = {
    Name = "${var.cluster_name}-node-group-custom-${var.environment}"
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only,
    aws_eks_cluster.test_cluster
  ]
}

data "aws_ami" "eks_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.test_cluster.version}-v*"]
  }
}

resource "aws_launch_template" "test_launch_template" {
  name = "test_launch_template"

  #vpc_security_group_ids = [module.network.node_sg]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }

  #need to see if we can do this and survive a scale out/scale in event
  #may also need for terraform destroy to work.
  network_interfaces {
    delete_on_termination = true
    security_groups       = [module.network.node_sg]
  }

  image_id      = data.aws_ami.eks_ami.id
  instance_type = "t3.medium"
  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="
--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
/etc/eks/bootstrap.sh ${var.cluster_name}
--==MYBOUNDARY==--\
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "EKS-MANAGED-NODE"
    }
  }
}

resource "aws_eks_node_group" "chonky" {
  count           = var.pod_sg_example ? 1 : 0
  cluster_name    = aws_eks_cluster.test_cluster.name
  version         = aws_eks_cluster.test_cluster.version
  node_group_name = "${var.cluster_name}-node-group-chonky-${var.environment}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.network.private_subnets
  #instance_types  = var.instance_types
  instance_types = ["m5.large"]

  labels = {
    "type" = "chonky"
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }

  tags = {
    Name = "${var.cluster_name}-node-group-chonky-${var.environment}"
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only,
    aws_eks_cluster.test_cluster
  ]
}