# ingress (node port) example


helm install npc-ingress-test ./examples/ingress_node_port/ingress_example_chart --set albSecurityGroup=$(terraform output --raw alb_security_group_id)



## Cleanup
