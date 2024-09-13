StreamNative Platform Installation Guide
------

This guide covers how to use StreamNative's Platform K8s operators to provision a Pulsar cluster and other components.
If you haven't already installed the operators, please refer to the [installation guide](https://docs.streamnative.io/private/private-cloud-quickstart)
for details.


### Provision a Pulsar cluster
The Pulsar Operator provides full lifecycle management for all the components within a Pulsar cluster. You can use it
to create, upgrade, and scale a cluster. This section covers how to deploy a Pulsar cluster on Kubernetes using the
Pulsar Operators by applying a single YAML file that contains the Custom Resources (CRs) of all the components required
to create a Pulsar cluster.

1️⃣ Create a Kubernetes namespace to deploy the Pulsar cluster into

```bash
export PULSAR_K8S_NAMESPACE=pulsar
kubectl create namespace $PULSAR_K8S_NAMESPACE
```

2️⃣ Install Pulsar

```bash
kubectl apply -f ./configs/02-pulsar-cluster.yaml --wait --namespace $PULSAR_K8S_NAMESPACE

pulsarcoordinator.k8s.streamnative.io/private-cloud unchanged
zookeepercluster.zookeeper.streamnative.io/pulsar-cluster configured
bookkeepercluster.bookkeeper.streamnative.io/pulsar-cluster configured
pulsarbroker.pulsar.streamnative.io/pulsar-cluster configured
pulsarproxy.pulsar.streamnative.io/pulsar-cluster configured
console.k8s.streamnative.io/pulsar-cluster created
```


3️⃣ Verify that all components of the Pulsar cluster are up and running.

```bash
kubectl get all -n $PULSAR_K8S_NAMESPACE

NAME                           READY   STATUS     RESTARTS   AGE
pod/pulsar-cluster-bk-0        0/1     Running    0          35s
pod/pulsar-cluster-bk-1        0/1     Running    0          35s
pod/pulsar-cluster-bk-2        0/1     Running    0          35s
pod/pulsar-cluster-broker-0    0/1     Running    0          26s
pod/pulsar-cluster-broker-1    0/1     Running    0          26s
pod/pulsar-cluster-broker-2    0/1     Running    0          26s
pod/pulsar-cluster-console-0   2/2     Running    0          43s
pod/pulsar-cluster-proxy-0     0/1     Init:0/1   0          77s
pod/pulsar-cluster-proxy-1     0/1     Init:0/1   0          77s
pod/pulsar-cluster-zk-0        1/1     Running    0          77s
pod/pulsar-cluster-zk-1        1/1     Running    0          77s
pod/pulsar-cluster-zk-2        1/1     Running    0          77s

NAME                                               TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                                                                   AGE
service/pulsar-cluster-bk                          ClusterIP      10.152.183.254   <none>          3181/TCP,8000/TCP                                                         35s
service/pulsar-cluster-bk-auto-recovery-headless   ClusterIP      None             <none>          3181/TCP,8000/TCP                                                         35s
service/pulsar-cluster-bk-headless                 ClusterIP      None             <none>          3181/TCP,8000/TCP                                                         35s
service/pulsar-cluster-broker                      ClusterIP      10.152.183.237   <none>          6650/TCP,8080/TCP,9092/TCP,8001/TCP,5672/TCP,5673/TCP,1883/TCP,5682/TCP   77s
service/pulsar-cluster-broker-external             LoadBalancer   10.152.183.76    192.168.0.101   5672:30054/TCP,5673:32052/TCP                                             77s
service/pulsar-cluster-broker-headless             ClusterIP      None             <none>          6650/TCP,8080/TCP,9092/TCP,8001/TCP,5672/TCP,5673/TCP,1883/TCP,5682/TCP   77s
service/pulsar-cluster-console                     ClusterIP      None             <none>          7750/TCP,9527/TCP                                                         43s
service/pulsar-cluster-proxy                       ClusterIP      10.152.183.126   <none>          6650/TCP,8080/TCP                                                         77s
service/pulsar-cluster-proxy-external              LoadBalancer   10.152.183.59    192.168.0.100   6650:31144/TCP,8080:32076/TCP                                             77s
service/pulsar-cluster-proxy-headless              ClusterIP      None             <none>          6650/TCP,8080/TCP                                                         77s
service/pulsar-cluster-zk                          ClusterIP      10.152.183.245   <none>          2181/TCP,8000/TCP,9990/TCP                                                77s
service/pulsar-cluster-zk-headless                 ClusterIP      None             <none>          2181/TCP,2888/TCP,3888/TCP,8000/TCP,9990/TCP                              77s

NAME                                               READY   AGE
statefulset.apps/pulsar-cluster-bk                 0/3     35s
statefulset.apps/pulsar-cluster-bk-auto-recovery   0/0     35s
statefulset.apps/pulsar-cluster-broker             0/3     26s
statefulset.apps/pulsar-cluster-console            1/1     43s
statefulset.apps/pulsar-cluster-proxy              0/2     77s
statefulset.apps/pulsar-cluster-zk                 3/3     77s

NAME                                                        REFERENCE                     TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/pulsar-cluster-broker   PulsarBroker/pulsar-cluster   <unknown>/80%   1         5         3          77s
horizontalpodautoscaler.autoscaling/pulsar-cluster-proxy    PulsarProxy/pulsar-cluster    <unknown>/80%   1         3         2          77s
```


4 Run a smoke test to confirm that the Pulsar cluster is functional

```bash
kubectl exec -it -n pulsar pod/pulsar-cluster-broker-0 /pulsar/bin/pulsar-perf produce persistent://public/default/test

2024-09-13T00:21:17,850+0000 [main] INFO  org.apache.pulsar.testclient.PerformanceProducer - Starting Pulsar perf producer with config: {
  "confFile" : "/pulsar/conf/client.conf",
  "serviceURL" : "pulsar://pulsar-cluster-broker.pulsar.svc.cluster.local:6650",
  "authPluginClassName" : "",
  "authParams" : "",
  "tlsTrustCertsFilePath" : "",
  "tlsAllowInsecureConnection" : false,
  "tlsHostnameVerificationEnable" : false,
  "maxConnections" : 1,
  "statsIntervalSeconds" : 0,
  "ioThreads" : 1,
  "enableBusyWait" : false,
  "listenerName" : null,
  "listenerThreads" : 1,
  "maxLookupRequest" : 50000,
  "deprecatedAuthPluginClassName" : null,
  "topics" : [ "persistent://public/default/test" ],
  "numTopics" : 1,
  "numTestThreads" : 1,
  "msgRate" : 100,
  "msgSize" : 1024,
  "numProducers" : 1,
  "separator" : "-",
  "sendTimeout" : 0,
  "producerName" : null,
  "adminURL" : "http://pulsar-cluster-broker.pulsar.svc.cluster.local:8080",
  "maxOutstanding" : 0,
  "maxPendingMessagesAcrossPartitions" : 0,
  "partitions" : null,
  "numMessages" : 0,
  "compression" : "NONE",
  "payloadFilename" : null,
  "payloadDelimiter" : "\\n",
  "batchTimeMillis" : 1.0,
  "disableBatching" : false,
  "batchMaxMessages" : 1000,
  "batchMaxBytes" : 4194304,
  "testTime" : 0,
  "warmupTimeSeconds" : 1.0,
  "encKeyName" : null,
  "encKeyFile" : null,
  "delay" : 0,
  "delayRange" : null,
  "setEventTime" : false,
  "exitOnFailure" : false,
  "messageKeyGenerationMode" : null,
  "producerAccessMode" : "Shared",
  "formatPayload" : false,
  "formatterClass" : "org.apache.pulsar.testclient.DefaultMessageFormatter",
  "transactionTimeout" : 10,
  "numMessagesPerTransaction" : 50,
  "isEnableTransaction" : false,
  "isAbortTransaction" : false,
  "histogramFile" : null
}

...
2024-09-13T00:21:19,208+0000 [pulsar-perf-producer-exec-1-1] INFO  org.apache.pulsar.testclient.PerformanceProducer - Created 1 producers
2024-09-13T00:21:27,917+0000 [main] INFO  org.apache.pulsar.testclient.PerformanceProducer - Throughput produced:     864 msg ---     86.4 msg/s ---      0.7 Mbit/s  --- failure      0.0 msg/s --- Latency: mean:   8.601 ms - med:   8.446 - 95pct:   9.772 - 99pct:  11.723 - 99.9pct:  18.391 - 99.99pct:  20.461 - Max:  20.461
2024-09-13T00:21:37,952+0000 [main] INFO  org.apache.pulsar.testclient.PerformanceProducer - Throughput produced:    1872 msg ---    100.0 msg/s ---      0.8 Mbit/s  --- failure      0.0 msg/s --- Latency: mean:   7.784 ms - med:   7.739 - 95pct:   8.328 - 99pct:   9.647 - 99.9pct:  12.988 - 99.99pct:  13.713 - Max:  13.713
2024-09-13T00:21:47,991+0000 [main] INFO  org.apache.pulsar.testclient.PerformanceProducer - Throughput produced:    2876 msg ---    100.0 msg/s ---      0.8 Mbit/s  --- failure      0.0 msg/s --- Latency: mean:   7.761 ms - med:   7.691 - 95pct:   8.309 - 99pct:   9.445 - 99.9pct:  14.419 - 99.99pct:  14.491 - Max:  14.491
2024-09-13T00:21:58,021+0000 [main] INFO  org.apache.pulsar.testclient.PerformanceProducer - Throughput produced:    3880 msg ---    100.0 msg/s ---      0.8 Mbit/s  --- failure      0.0 msg/s --- Latency: mean:   7.732 ms - med:   7.646 - 95pct:   8.260 - 99pct:   9.834 - 99.9pct:  20.192 - 99.99pct:  25.798 - Max:  25.798

```


