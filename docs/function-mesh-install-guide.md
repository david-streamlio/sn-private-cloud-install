# Getting started with the Function Mesh Operator

Function Mesh is a serverless framework purpose-built for stream processing applications. It brings powerful 
event-streaming capabilities to your applications by orchestrating multiple Pulsar Functions and Pulsar IO connectors 
for complex stream processing jobs.

## Concepts
A FunctionMesh (aka Mesh) is a collection of functions and connectors connected by streams that are orchestrated 
together for achieving powerful stream processing logics. All the functions and connectors in a FunctionMesh share the 
same lifecycle. They are started when a FunctionMesh is created and terminated when the mesh is destroyed. All the event
processors are long running processes. They are auto-scaled based on the workload by the Function Mesh controller.

A FunctionMesh can be either a Directed Acyclic Graph (DAG) or a cyclic graph of functions and/or connectors connected 
with streams.

![function-mesh-diagram.png](images%2Ffunction-mesh%2Ffunction-mesh-diagram.png)

## APIs
Function Mesh APIs build on existing Kubernetes APIs, so that Function Mesh resources are compatible with other 
Kubernetes-native resources, and can be managed by cluster administrators using existing Kubernetes tools.

The benefit of this approach is both the function metadata and function running state are directly stored and managed by
Kubernetes to avoid the inconsistency problem that was seen using Pulsar's existing Kubernetes scheduler.

![function-mesh-internals.png](images%2Ffunction-mesh%2Ffunction-mesh-internals.png)

Requirements
------------
- kubectl (v1.16 or higher), compatible with your cluster (+/- 1 minor release from your cluster).
- Helm (v3.0.2 or higher).
- Kubernetes cluster (v1.16 or higher).


### Install Certification Manager

The function mesh operator requires CA certificates, and thus before we begin the installation, we must first install
the certificate manager on our K8s cluster.

1️⃣ Enable the cert-manager addon 

Since I am using microk8s, we can use the following command

```bash
microk8s enable cert-manager
```


2️⃣ Install Function Mesh using Helm

```bash
helm repo add function-mesh http://charts.functionmesh.io/
helm repo update

export FUNCTION_MESH_RELEASE_NAME=function-mesh  # change the release name according to your scenario
export FUNCTION_MESH_RELEASE_NAMESPACE=function-mesh  # change the namespace to where you want to install Function Mesh
helm install ${FUNCTION_MESH_RELEASE_NAME} function-mesh/function-mesh-operator -n ${FUNCTION_MESH_RELEASE_NAMESPACE}
```


3️⃣ Verify that all components are up and running

```bash
kubectl get pods -n ${FUNCTION_MESH_RELEASE_NAMESPACE} -l app.kubernetes.io/instance=function-mesh

NAME                                                READY   STATUS    RESTARTS   AGE
function-mesh-controller-manager-5ccb9fdf8c-7gltr   1/1     Running   0          19s
```


References
---
1. https://github.com/streamnative/function-mesh
2. https://functionmesh.io/docs/install-function-mesh/#install-function-mesh-through-helm
