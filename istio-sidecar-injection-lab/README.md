# Istio Sidecar Injection Lab — CKS practice

## Goal
Namespace `team-sedum` contains Deployment `one`, Deployment `two`, and Service `two`.
The namespace starts without the Istio injection label so you can solve the task yourself.

## Create the initial environment
```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-apps.yaml
kubectl get pods -n team-sedum
```

## Exercise (do not read solution first)
1. Enable Istio sidecar injection for the entire `team-sedum` namespace.
2. Ensure current Pods are recreated so they receive `istio-proxy`.
3. Verify that future Pods will also be injected.

Useful checks:
```bash
kubectl get namespace team-sedum --show-labels
kubectl get pods -n team-sedum
kubectl get pods -n team-sedum -o jsonpath='{range .items[*]}{.metadata.name}{": "}{.spec.containers[*].name}{"\n"}{end}'
```

## Hint
Setting a namespace label affects Pods created afterward, not already-running Pods.
Recreate existing Pods after enabling injection, for example by restarting the Deployments.

## Cleanup
```bash
kubectl delete namespace team-sedum
```
