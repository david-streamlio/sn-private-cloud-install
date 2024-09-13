StreamNative Monitoring
------


### Access the StreamNative Cloud Console
The StreamNative console is....

1️⃣ Expose the StreamNative console using the following command
```
kubectl expose svc pulsar-cluster-console --name pulsar-cluster-console-external -n pulsar --port 9527 --target-port 9527 --type LoadBalancer
```

Next, run the following command to see what external IP address was assigned to the console.

```
kubectl -n $PULSAR_K8S_NAMESPACE get svc | grep console-external
pulsar-cluster-console-external            LoadBalancer   10.152.183.207   192.168.0.103   9527:30438/TCP
```

Then you can access the console UI at `http://192.168.0.103:9527` using username/password 



### Enable Monitoring and Observability

See the StreamNative [docs](https://docs.streamnative.io/private/private-cloud-monitor#install-monitoring-stacks) for details.

1️⃣ Expose the Grafana dashboard using the following command:

```
kubectl expose svc grafana --name grafana-external -n monitor --port 3000 --target-port 3000 --type LoadBalancer
```

Next, run the following command to see what external IP address was assigned to the console.

```
kubectl -n monitor get svc | grep grafana-external
grafana-external                      LoadBalancer   10.152.183.25    192.168.0.102   3000:31100/TCP   21d
```

Get the Grafana password using the following command:

```
kubectl get secret --namespace monitor grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

J7H8c6ig0vJG6ZDmuJBnDK7XbrCuwFlfWPomOORV
```

Then you can access the console UI at `http://192.168.0.102:3000` using the username `admin` and the password you retrieved in the previous step.
