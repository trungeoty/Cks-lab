# Istio CKS Practice Lab

## Prerequisites
- A working Kubernetes cluster and kubectl context.
- Istio installed first. This bundle does not install the Istio control plane.
- `istioctl` available on the admin workstation.
- A CNI that enforces Kubernetes NetworkPolicy for the NetworkPolicy exercise.

## 1. Install Istio (learning cluster only)
```bash
istioctl install --set profile=demo -y
kubectl get pods -n istio-system
```

## 2. Deploy baseline workloads
Apply in this order:
```bash
kubectl apply -f 00-namespaces.yaml
kubectl apply -f 01-apps.yaml
kubectl apply -f 02-secure-workloads.yaml
kubectl apply -f 07-isolation-workloads.yaml
kubectl get pods -A
```
The namespaces have `istio-injection=enabled`. New pods should have an `istio-proxy` container. If workloads were already running before the namespace label was applied, restart them:
```bash
kubectl rollout restart deployment -n istio-lab
kubectl rollout restart deployment -n istio-secure
kubectl rollout restart deployment -n istio-isolation
```

## 3. Test service connectivity
```bash
kubectl exec -n istio-lab deploy/curl-client -c curl -- \
  curl -sS http://backend.istio-lab.svc.cluster.local
```
Nginx should return its welcome page HTML.

## 4. Practice mTLS
First test baseline connectivity:
```bash
kubectl exec -n istio-secure deploy/secure-client -c curl -- \
  curl -sS -o /dev/null -w '%{http_code}\n' http://secure-server.istio-secure.svc.cluster.local
```
Apply STRICT mTLS:
```bash
kubectl apply -f 03-peer-authentication-mtls.yaml
```
Retest. Requests between injected sidecars should use mTLS. To inspect proxy configuration:
```bash
istioctl proxy-status
istioctl authn tls-check deploy/secure-server.istio-secure
```

## 5. Practice AuthorizationPolicy
Apply the policy:
```bash
kubectl apply -f 04-authorization-policy.yaml
```
This policy allows requests from the default ServiceAccount principal in `istio-secure` to `secure-server`. For a more distinct allow/deny exercise, create a second client using a different ServiceAccount and test it against the server. Remember: ALLOW policies are additive and, once an ALLOW policy selects a workload, requests not matching any ALLOW rule are denied.

## 6. Practice ingress routing
```bash
kubectl apply -f 05-ingress-gateway-virtualservice.yaml
kubectl get svc -n istio-system istio-ingressgateway
```
If using a LoadBalancer, use its external address. For a local cluster, port-forward:
```bash
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
```
In another terminal:
```bash
curl -H 'Host: lab.example.com' http://127.0.0.1:8080/
```

## 7. Practice NetworkPolicy
Apply workloads first, then:
```bash
kubectl apply -f 06-network-policy-deny-ingress.yaml
```
Test connectivity to `web` from `test-client`; ingress should be blocked if your CNI enforces NetworkPolicy. This is a Kubernetes NetworkPolicy exercise, not an Istio policy. In an Istio mesh, validate interactions with your CNI and sidecar setup.

## 8. Cleanup
```bash
kubectl delete namespace istio-lab istio-secure istio-isolation
```
To remove Istio itself (only if this is a dedicated lab cluster):
```bash
istioctl uninstall --purge -y
kubectl delete namespace istio-system
```

## Notes
- Use this only in a disposable learning cluster, not production.
- Image tags may need adjustment to match your cluster's architecture and registry policy.
- Istio API versions can vary by installed release. If an Istio CRD rejects `security.istio.io/v1` or `networking.istio.io/v1`, check installed CRDs and use the API version supported by that release.
- CKS itself focuses on Kubernetes security; Istio-specific exercises are supplementary practice.
