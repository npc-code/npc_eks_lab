# autoscaling example

## Steps

1. Use kubectl to deploy the ```nginx_to_scale.yaml``` file: ```kubectl apply -f nginx_to_scale.yaml```
2. Observe the running pods: ```kubectl get pods```
  - your output should be similar to:

3. Observe the cluster's current nodes:  ```kubectl get nodes```.  You should only see 2 nodes if the cluster has just been launched.
4. Scale the deployment: ```kubectl  