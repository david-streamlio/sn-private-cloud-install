Ververica Platform Installation Guide
------
This guide covers how to install the Ververica Platform for Flink, and is based on their 
installation [guide](https://docs.ververica.com/vvp/getting-started/installation/).

### 1. Create the Kubernetes namespace
Before installing any of the components, we need to create the Kubernetes namespaces vvp and vvp-jobs with the 
following command:

```bash
kubectl create namespace vvp
kubectl create namespace vvp-jobs
```

### 2. Install MinIO with Helm
In addition to Ververica Platform, we will set up MinIO in the vvp namespace, which will be used for artifact storage 
and Apache Flink® checkpoints & savepoints as shown in diagram below:

![Ververica-Deployment.png](..%2Fimages%2Fververica%2FVerverica-Deployment.png)

If you have never added the stable Helm repository, first use the following command to add it

```bash
helm repo add stable https://charts.helm.sh/stable
```

Next, install MinIO with the following command:

```bash
helm --namespace vvp \
  install minio stable/minio \
  --values configs/ververica/values-minio.yaml
```

### 3. Install the Ververica Platform
Now we are ready to install Ververica Platform using helm. 

If you have never added the stable Helm repository, first use the following command to add it

```bash
helm repo add ververica https://charts.ververica.com
```

Next, install MinIO with the following command:

```bash
helm install vvp ververica/ververica-platform \
  --namespace vvp \
  --values configs/ververica/values-vvp.yaml \
  --values configs/ververica/values-license.yaml
```

Finally, verify that all components of the Ververica cluster are up and running.

```bash
kubectl get all -n vvp

NAME                                          READY   STATUS    RESTARTS   AGE
pod/minio-564975d79-mwxl8                     1/1     Running   0          20h
pod/vvp-ververica-platform-57df8ff95b-ljxkz   3/3     Running   0          16h

NAME                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/minio                    ClusterIP   10.152.183.145   <none>        9000/TCP   20h
service/vvp-ververica-platform   ClusterIP   10.152.183.240   <none>        80/TCP     16h

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/minio                    1/1     1            1           20h
deployment.apps/vvp-ververica-platform   1/1     1            1           16h

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/minio-564975d79                     1         1         1       20h
replicaset.apps/vvp-ververica-platform-57df8ff95b   1         1         1       16h
replicaset.apps/vvp-ververica-platform-76fc6f6558   0         0         0       16h
```

### 4. Expose the Web UI
Rather than using port-forwarding, you can run the following command to create a load balancer in front of the Ververica
web user interface by running the following command:

```bash
kubectl apply -f configs/ververica/webui-load-balancer.yaml
```

The web interface and API are now available at 192.168.0.204:8080 as shown here:

![Ververica-UI.png](..%2Fimages%2Fververica%2FVerverica-UI.png)