# autoscaling example

Simple example to demonstrate cluster autoscaling behavior.  Taken from: https://www.eksworkshop.com/

## Steps

1. Use kubectl to deploy the ```nginx_to_scale.yaml``` file: ```kubectl apply -f nginx_to_scale.yaml```
2. Observe the running pods: ```kubectl get pods```
  - your output should be similar to:

3. Observe the cluster's current nodes:  ```kubectl get nodes```.  You should only see 2 nodes if the cluster has just been launched.
4. Scale the deployment: ```kubectl scale --replicas=10 deployment/nginx-to-scaleout```
5. Observe pods in pending state: ```kubectl get pods```
6. Eventually new nodes will be launched.  You can observe the autoscaler logs with:  ```kubectl -n kube-system logs -f deployment/cluster-autoscaler```
7. Once the new nodes are available, the pods in a pending state should now be running.
8. To observe scaledown behavior, execute: ```kubectl scale --replicas=1 deployment/nginx-to-scaleout```
  - the default behavior of the autoscaler is to watch nodes that could be removed for 10 minutes.  once 10 minutes have passed, the nodes will be tainted and then removed.

## Cleanup

```kubectl delete -f nginx_to_scale.yaml```