StreamNative Platform Installation Guide
------

This guide covers how to use StreamNative's Platform K8s operators to provision a Pulsar cluster and other components.
If you haven't already installed the operators, please refer to the [installation guide](https://docs.streamnative.io/private/private-cloud-quickstart)
for details.

### 1. Create the operators namespace
First, you need to create a Kubernetes namespace for the StreamNative operators to run inside. 

```bash
kubectl create namespace operators
```

### 2. Import license

Before installing StreamNative Private Cloud, you need to import a valid license. Otherwise, StreamNative Private Cloud 
will stop reconciling with a "no valid license" error message. Running the following command will create a K8s secret
containing a valid license key in the `operators` namespace that we created in the previous step.

```bash
kubectl apply -f configs/StreamNative/license.yaml
```

### 3. Install the StreamNative Operator

1️⃣ Add the StreamNative chart repository.

```bash
helm repo add streamnative https://charts.streamnative.io
helm repo update
```

2️⃣ Deploy the StreamNative Operator using the sn-operator Helm chart.

```bash
helm install sn-operator streamnative/sn-operator -n operators
```

3️⃣ Verify that the operator pods are up and running.

```bash
kubectl get all -n operators
```

### 4. Provision a Pulsar cluster
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
kubectl apply -f ./configs/streamnative/01_pulsar-cluster.yaml --wait --namespace $PULSAR_K8S_NAMESPACE

pulsarcoordinator.k8s.streamnative.io/private-cloud created
zookeepercluster.zookeeper.streamnative.io/private-cloud created
bookkeepercluster.bookkeeper.streamnative.io/private-cloud created
pulsarbroker.pulsar.streamnative.io/private-cloud created
pulsarproxy.pulsar.streamnative.io/private-cloud created
console.k8s.streamnative.io/private-cloud created
```


3️⃣ Verify that all components of the Pulsar cluster are up and running.

```bash
kubectl get all -n $PULSAR_K8S_NAMESPACE

NAME                                   READY   STATUS    RESTARTS   AGE
pod/private-cloud-bk-0                 1/1     Running   0          115s
pod/private-cloud-bk-1                 1/1     Running   0          115s
pod/private-cloud-bk-2                 1/1     Running   0          115s
pod/private-cloud-bk-auto-recovery-0   1/1     Running   0          72s
pod/private-cloud-broker-0             1/1     Running   0          108s
pod/private-cloud-broker-1             1/1     Running   0          108s
pod/private-cloud-broker-2             1/1     Running   0          108s
pod/private-cloud-console-0            2/2     Running   0          2m39s
pod/private-cloud-proxy-0              1/1     Running   0          2m39s
pod/private-cloud-toolset-0            1/1     Running   0          2m39s
pod/private-cloud-zk-0                 1/1     Running   0          2m39s
pod/private-cloud-zk-1                 1/1     Running   0          2m39s
pod/private-cloud-zk-2                 1/1     Running   0          2m39s

NAME                                              TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                                        AGE
service/private-cloud-bk                          ClusterIP      10.152.183.38    <none>          3181/TCP,8000/TCP                              115s
service/private-cloud-bk-auto-recovery-headless   ClusterIP      None             <none>          3181/TCP,8000/TCP                              115s
service/private-cloud-bk-headless                 ClusterIP      None             <none>          3181/TCP,8000/TCP                              115s
service/private-cloud-broker                      ClusterIP      10.152.183.89    <none>          6650/TCP,8080/TCP                              2m39s
service/private-cloud-broker-headless             ClusterIP      None             <none>          6650/TCP,8080/TCP                              2m39s
service/private-cloud-console                     ClusterIP      None             <none>          7750/TCP,9527/TCP                              2m39s
service/private-cloud-proxy                       ClusterIP      10.152.183.189   <none>          6650/TCP,8080/TCP                              2m39s
service/private-cloud-proxy-external              LoadBalancer   10.152.183.118   192.168.0.200   6650:32432/TCP,8080:30595/TCP                  2m39s
service/private-cloud-proxy-headless              ClusterIP      None             <none>          6650/TCP,8080/TCP                              2m39s
service/private-cloud-toolset                     ClusterIP      None             <none>          <none>                                         2m39s
service/private-cloud-zk                          ClusterIP      10.152.183.205   <none>          2181/TCP,8000/TCP,9990/TCP                     2m39s
service/private-cloud-zk-headless                 ClusterIP      None             <none>          2181/TCP,2888/TCP,3888/TCP,8000/TCP,9990/TCP   2m39s

NAME                                              READY   AGE
statefulset.apps/private-cloud-bk                 3/3     115s
statefulset.apps/private-cloud-bk-auto-recovery   1/1     115s
statefulset.apps/private-cloud-broker             3/3     108s
statefulset.apps/private-cloud-console            1/1     2m39s
statefulset.apps/private-cloud-proxy              1/1     2m39s
statefulset.apps/private-cloud-toolset            1/1     2m39s
statefulset.apps/private-cloud-zk                 3/3     2m39s
```


### 5. Run a smoke test to confirm that the Pulsar cluster is functional

```bash
kubectl exec -it -n pulsar pod/private-cloud-toolset-0 /pulsar/bin/pulsar-perf produce persistent://public/default/test

2025-02-25T00:47:59,549+0000 [main] INFO  org.apache.pulsar.testclient.PerformanceProducer - Starting Pulsar perf producer with config: {
  "confFile" : "/pulsar/conf/client.conf",
  "serviceURL" : "http://private-cloud-broker.pulsar.svc.cluster.local:8080",
  "authPluginClassName" : null,
  "authParams" : null,
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
  "adminURL" : "http://private-cloud-broker.pulsar.svc.cluster.local:8080",
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
2025-02-25T00:47:59,557+0000 [pulsar-perf-producer-exec-1-1] INFO  org.apache.pulsar.testclient.PerformanceProducer - Started performance test thread 0
2025-02-25T00:48:01,469+0000 [pulsar-perf-producer-exec-1-1] INFO  org.apache.pulsar.testclient.PerformanceProducer - Adding 1 publishers on topic persistent://public/default/test
2025-02-25T00:48:04,165+0000 [pulsar-client-io-2-1] INFO  org.apache.pulsar.client.impl.ConnectionPool - [[id: 0x94d2ae56, L:/10.1.128.164:50180 - R:private-cloud-broker-2.private-cloud-broker-headless.pulsar.svc.cluster.local/10.1.128.135:6650]] Connected to server
2025-02-25T00:48:04,243+0000 [pulsar-client-io-2-1] INFO  org.apache.pulsar.client.impl.ProducerImpl - [persistent://public/default/test] [null] Creating producer on cnx [id: 0x94d2ae56, L:/10.1.128.164:50180 - R:private-cloud-broker-2.private-cloud-broker-headless.pulsar.svc.cluster.local/10.1.128.135:6650]
2025-02-25T00:48:05,835+0000 [pulsar-client-io-2-1] INFO  org.apache.pulsar.client.impl.ProducerImpl - [persistent://public/default/test] [private-cloud-1-0] Created producer on cnx [id: 0x94d2ae56, L:/10.1.128.164:50180 - R:private-cloud-broker-2.private-cloud-broker-headless.pulsar.svc.cluster.local/10.1.128.135:6650]
2025-02-25T00:48:05,840+0000 [pulsar-perf-producer-exec-1-1] INFO  org.apache.pulsar.testclient.PerformanceProducer - Created 1 producers
2025-02-25T00:48:09,606+0000 [main] INFO  org.apache.pulsar.testclient.PerformanceProducer - Throughput produced:     371 msg ---     37.1 msg/s ---      0.3 Mbit/s  --- failure      0.0 msg/s --- Latency: mean:   6.323 ms - med:   6.152 - 95pct:   7.265 - 99pct:   9.081 - 99.9pct:  11.126 - 99.99pct:  11.126 - Max:  11.126
2025-02-25T00:48:19,676+0000 [main] INFO  org.apache.pulsar.testclient.PerformanceProducer - Throughput produced:    1381 msg ---    100.0 msg/s ---      0.8 Mbit/s  --- failure      0.0 msg/s --- Latency: mean:   5.341 ms - med:   5.133 - 95pct:   5.845 - 99pct:   8.022 - 99.9pct:  34.471 - 99.99pct:  38.268 - Max:  38.268

```


