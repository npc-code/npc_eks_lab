# npc_eks_lab

Terraform project for creating an eks cluster for lab purposes.  Will create:
- vpc with a public/private/cluster eni subnet per az in the region you deploy to
- security groups and rules for worker nodes, an alb, and the cluster
- an eks cluster
- 2 managed node groups, one using a launch template and the other using bare-minimum config
- iam roles and policies for the cluster and worker nodes
- iam roles and policies to be used in conjunction with service accounts
- 2 service accounts for use with autoscaling and the ingress controller (cluster autoscaler and ingress controller are deployed using Helm provider)

## Requirements
- terraform
- aws account, profile with elevated permissions
- kubectl (https://kubernetes.io/docs/tasks/tools/)

## Use
- create a variable file ($WHATEVER.auto.tfvars):
```hcl
profile      = $name_of_your_aws_profile
base_network = "10.102.0.0"
environment  = "development"
cluster_name = "my_cluster"
external_ip  = "$YOUR_IP/32"
```
  the ```external_ip``` variable is used to restrict incoming communication to the k8s api server to your ip, as well as limiting access to any ingress controller deployed.
- Execute:
```
terraform init
terraform plan
terraform apply
```
- Get coffee.  Cluster will take ~12 minutes to create, other resources ~5 minutes.

- Update kubeconfig (see: https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html for more options):
```
aws eks --region REGION_CODE --profile YOUR_PROFILE update-kubeconfig --name my_cluster
```

- Test your setup:
```
kubectl get nodes
```

## Examples
-  [**Cluster Autoscaling**](/examples/autoscaling/autoscale_example.md)
-  [**Ingress Controller (node port)**](/examples/ingress_node_port/ingress_example.md)



## Considerations
- The lab aims to demonstrate what is needed if a user were to create an eks cluster using Terraform and chooses to pass a security group. It is important to understand that if the version used for the cluster is >= 1.14, a security group will be created automatically.  If you do not use a launch template when dealing with managed node groups, your nodes will be placed in this security group by default.  In this lab, the custom managed node group uses a separate security group that is passed to the cluster resource.  Appropriate security group rules are included.  Awareness and consideration of this reality should dictate the approach used in actual production.
- The security group rules are based on recommendations from the AWS documentation.  More restrictive rules would be advised in production.
- IAM policies are based off of recommended AWS policies.  Exploring more restrictive policies for the autoscaler and load-balancer-controller should be explored.    
- for your ```base_cidr```, avoid ```10.100.0.0```.  This is the default for pod networking within the cluster.
- The private subnets are not private.  To keep cost and use of finite resources at a minimum, no NAT gateways are created.
- The output from terraform includes the server endpoint and certificate info.  you will need to insert this into a context within ~/.kube/config, or create your own separate kube-config file.
- This lab will incur costs if left up.  EKS clusters cost $0.10 per hour, and running the 2 node groups using the default t3.medium at minimum capacity will cost 2 x ($0.0416) per hour.  Costs for data transfer over internet gateway should be negligible.  I take no responsibility for unexpected charges.







