
# ingress (cluster ip) example

simple example highlighting the use of the aws ingress controller using cluster ip and pod security groups.

# Steps
1. Ensure that ```pod_sg_example``` is set to ```true```.  The default t3 instance class used in the other example node groups is not compatible.  Note that this example will use a m5.large instance with the associated additional costs.
2. run: ```kubectl -n kube-system set env daemonset aws-node ENABLE_POD_ENI=true```
 - this is needed to enable the networking requirements for pod security groups 
3. ```helm install npc-ingress-test-cluster-ip ./examples/ingress_cluster_ip/ingress_cluster_ip_chart --set albSecurityGroup=$(terraform output --raw alb_security_group_id) --set podSecurityGroup=$(terraform output --raw pod_security_group_id)```
4.  run: ```kubectl get ingress``
 - note the ingress address, visit to confirm.


# Cleanup
1. ```helm uninstall npc-ingress-test-cluster-ip```
  - very important that this is done before tearing down the lab.  since the ingress resource deployed as part of the chart will create alb, terraform has no way of knowing about it. executing a terraform destroy with removing this chart will hang the process, and you will need to remove some aws resources manually.