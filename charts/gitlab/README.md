## \[DRAFT\] Hints for creating gitlab kubernetes cluster via HELM
1. Redis secret  (redis-gitlab):
    ```bash
    kubectl create secret generic redis-gitlab --namespace gitlab --from-literal=password="$(openssl rand -base64 24)" --from-literal=redis-password="$(openssl rand -base64 24)"
    ```
2. Object storage secret (gitlab-object-storage):
   1. object_storage.yaml
    ```yaml
    provider: Google
    google_project: organization-project
    google_client_email: null
    google_json_key_string: null
    ```
   2. create
    ```bash
    kubectl create secret generic gitlab-object-storage --namespace gitlab --from-file=connection=object_storage.yaml
    ```
3. Secret for OIDC:
   1. `provider_secret_oidc.yaml`
    ```yaml
    name: 'openid_connect'
    label: 'Google Login'
    args:
      name: 'openid_connect'
      scope: ['openid', 'profile', 'email']
      issuer: 'https://accounts.google.com'
      client_auth_method: 'query'
      uid_field: 'preferred_username'
      pkce: true
      response_type: 'code'
      discovery: true
      client_options:
        identifier: '<client ID>'
        secret: '<Client Secret>'
        redirect_uri: 'https://<Gitlab URL>/users/auth/openid_connect/callback'
    ```
   2. Create secret
    ```bash
    kubectl create secret generic gitlab-oidc-secret --namespace gitlab --from-file=provider=provider_secret_oidc.yaml
    ```
4. Which buckets should be created for gitlab: lfs, artifacts, uploads, packages, backups, tmp.
5. Map postgres SA in gitlab namespace to postgres via gcp Workload identity mapping
6. Map KSA for every gitlab service (like gcp-int-gitlab-webservice) with GSA in Workload identity mapping

## Checks:
1. Check if is Workload Identity have right service account
```bash
    kubectl exec -n <namespace name> -it <pod-name> -- \
    curl -H "Metadata-Flavor: Google" \
    http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/email
```

## Solve problems
1. Delete project in Gitlab if a PV was recreated (gitaly in STS mode)
   1. Connect to gitlab-rake console 
    ```
    kubectl exec -it <gitlab toolbox pod> -n gitlab -- gitlab-rails console
    ```
   2. Delete project
    ```
     project = Project.find_by_full_path("group/project")
     project.destroy!
    ``` 