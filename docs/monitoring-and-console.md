StreamNative Monitoring
-----


### Access the StreamNative Cloud Console
The StreamNative console is

1️⃣ Expose the StreamNative console using the following command
```
kubectl expose svc private-cloud-console --name private-cloud-console-external -n pulsar --port 9527 --target-port 9527 --type LoadBalancer
```

Next, run the following command to see what external IP address was assigned to the console.

```
kubectl -n $PULSAR_K8S_NAMESPACE get svc | grep console-external

private-cloud-console-external            LoadBalancer   10.152.183.173   192.168.0.202   9527:31589/TCP
```

Then you can access the console UI at `http://192.168.0.202:9527` 



### Enable Monitoring and Observability

See the StreamNative [docs](https://docs.streamnative.io/private/private-cloud-monitor#install-monitoring-stacks) for details.

1. Install the latest prometheus server using Helm

```bash
kubectl create ns monitor

helm install prometheus prometheus-community/prometheus -n monitor --set alertmanager.enabled=false --set kube-state-metrics.enabled=false --set prometheus-pushgateway.enabled=false

Release "prometheus" has been upgraded. Happy Helming!
NAME: prometheus
LAST DEPLOYED: Mon Feb 24 17:57:59 2025
NAMESPACE: monitor
STATUS: deployed
REVISION: 2
```

1️⃣ Install Grafana and expose the Grafana dashboard using the following command:

```
helm install grafana grafana/grafana -n monitor --set image.repository=streamnative/private-cloud-grafana --set image.tag=0.1.1

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

Next, configure the Prometheus Server Data source in Grafana using the local IP address of the `prometheus-server`, which can
be found using the following command: `kubectl -n monitor get svc prometheus-server` as shown here.

![prometheus-server - - Grafana.png](..%2Fimages%2Fprometheus-server%20-%20-%20Grafana.png)
