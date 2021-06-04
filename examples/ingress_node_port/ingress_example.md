# ingress (node port) example

simple example highlighting the use of the aws ingress controller.  Based on lab in: https://www.eksworkshop.com/

## Steps
1.  ```helm install npc-ingress-test ./examples/ingress_node_port/ingress_example_chart --set albSecurityGroup=$(terraform output --raw alb_security_group_id)```
  - this will deploy a very simple helm chart, with the only the id of the alb security group being passed.
2.  Get the address of the alb: ```kubectl get ingress```.  The dns entry will be displayed.

## Cleanup

run: ```helm uninstall npc-ingress-test```
  - very important that this is done before tearing down the lab.  since the ingress resource deployed as part of the chart will create alb, terraform has no way of knowing about it. executing a terraform destroy with removing this chart will hang the process, and you will need to remove some aws resources manually.