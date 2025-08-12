# HAProxy
Reverse proxy operating on the edge (munyard.dev), proxies to the stuff running inside network.

## Generate a self signed certificate
Set SSL/TLS mode to 'Full' (not strict!). Allows CloudFlare to accept self signed certificate.

Generate the SSL cert:

```sh
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.yaml


cat ss-issuer.yaml << EOF 
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF

kubectl apply -f ss-issuer.yaml

cat > ss-certificate.yaml << EOF 
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: munyard-dev-tls
  namespace: ha-proxy
spec:
  secretName: munyard-dev-tls
  dnsNames:
  - "munyard.dev"
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
EOF

kubectl apply -f ss-certificate.yaml
```

## (Obsolete) Generate signed certificate
(Back when we hosted on GCP)

The SSL cert for munyard.dev is auto renewed by the [cronjob.yaml](cronjob.yaml). Followed this guide: https://russt.me/2018/04/wildcard-lets-encrypt-certificates-with-certbot/

- Create a secret from the GCP credentials `kubectl create secret generic gcp-credentials --from-file credentials.json=./elbanyo-c215a55008fe.json --namespace ha-proxy`
- Deploy the cronjob
```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ha-proxy-certbot
  namespace: ha-proxy
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ha-proxy
  name: configmap-creator
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["configmaps"]
  verbs: ["create", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: create-configmaps
  namespace: ha-proxy
subjects:
- kind: ServiceAccount
  name: ha-proxy-certbot
  namespace: ha-proxy
roleRef:
  kind: Role
  name: configmap-creator
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: ha-proxy-certs
  namespace: ha-proxy
data:
  munyard.dev: ""
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: create-configmap-sh
  namespace: ha-proxy
data:
  create-configmap.sh: | 
    #!/bin/sh

    # Install curl, jo
    apk add --no-cache curl jo

    # Point to the internal API server hostname
    APISERVER=https://kubernetes.default.svc

    # Path to ServiceAccount token
    SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount

    # Read this Pod's namespace
    NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

    # Read the ServiceAccount bearer token
    TOKEN=$(cat ${SERVICEACCOUNT}/token)

    # Reference the internal certificate authority (CA)
    CACERT=${SERVICEACCOUNT}/ca.crt

    # Set domain name
    DOMAIN=munyard.dev

    # Set name of ConfigMap containing the certificate bundle
    CONFIGMAP=ha-proxy-certs

    # Update SSL certificate
    # jo -p pretty prints the JSON just for logging what we're patching. jo -a wraps the JSON as an array
    jo -p -a "$(jo op=replace path=/data value="$(jo ${DOMAIN}="$(cat /certs/live/${DOMAIN}/fullchain.pem /certs/live/${DOMAIN}/privkey.pem)")")"
    
    # Generate the JSON patch and PATCH it to the Kubernetes API
    jo -a "$(jo op=replace path=/data value="$(jo ${DOMAIN}="$(cat /certs/live/${DOMAIN}/fullchain.pem /certs/live/${DOMAIN}/privkey.pem)")")" | curl --data "@-" --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json-patch+json" -X PATCH ${APISERVER}/api/v1/namespaces/ha-proxy/configmaps/${CONFIGMAP}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: certificate-renewal-job
  namespace: ha-proxy
spec:
  # At 00:00, on day 1 of the month, every 3 months
  schedule: "0 0 1 */3 *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: ha-proxy-certbot
          restartPolicy: Never
          containers:
            - name: certificate-deploy
              image: alpine
              command: ["/bin/sh"]
              args: ["-c", "./scripts/create-configmap.sh"]
              imagePullPolicy: Always
              resources:
                requests:
                  memory: "64Mi"
                  cpu: "250m"
                limits:
                  memory: "128Mi"
                  cpu: "500m"
              volumeMounts:
                - name: etc-letsencrypt
                  mountPath: /certs
                - name: create-configmap-sh
                  mountPath: /scripts
          initContainers:
            - name: certbot
              image: certbot/dns-google:arm64v8-latest
              imagePullPolicy: Always
              args: ["certonly", "--dns-google", "--dns-google-credentials", "/gcp/credentials.json", "-d", "munyard.dev,plex.munyard.dev,sab.munyard.dev,qb.munyard.dev,sonarr.munyard.dev,radarr.munyard.dev,pm.munyard.dev,www.munyard.dev", "--agree-tos", "--email", "dmunyard@gmail.com", "--non-interactive"]
              resources:
                requests:
                  memory: "64Mi"
                  cpu: "250m"
                limits:
                  memory: "128Mi"
                  cpu: "500m"
              volumeMounts:
                - name: gcp-credentials
                  mountPath: "/gcp"
                - name: etc-letsencrypt
                  mountPath: /etc/letsencrypt
          volumes:
            - name: gcp-credentials
              secret:
                secretName: gcp-credentials
            - name: etc-letsencrypt
              emptyDir: {}
            - name: create-configmap-sh
              configMap:
                name: create-configmap-sh
                defaultMode: 0777
```

### What does it do
The CronJob runs at midnight on the first day of Feb, April, June, August, October, December. 

It uses certbot to request an SSL certificate for munyard.dev and all sub domains. 

After the certificate is issued, the CronJob will deploy the certificate to a ConfigMap called `ha-proxy-certs` which is mounted by the ha-proxy container to access the SSL certificate.

## 3. Deploy ha-proxy config
`kubectl apply -f config.yaml`

Config needs to end with a empty newline.

# 4. Deploy ha-proxy
`kubectl apply -f deployment.yaml`
