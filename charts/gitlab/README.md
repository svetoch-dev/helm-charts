## \[DRAFT\] Hints for creating gitlab kubernetes cluster via HELM
## Which secrets are important to create by yourself:
1. Redis secret  (redis-gitlab):
    ```bash
    kubectl create secret generic redis-gitlab   --namespace gitlab   --from-literal=password="$(openssl rand -base64 24)"   --from-literal=redis-password="$(openssl rand -base64 24)"
    ```
2. Object storage secret (gitlab-object-storage):
   1. object_storage.yaml
    ```yaml
    provider: Google
    google_project: organization-project
    google_application_default: true
    ```
   2. create
    ```bash
    kubectl create secret generic gitlab-object-storage   --namespace gitlab   --from-file=connection=object_storage.yaml
    ```
3. Map postgres SA in gitlab namespace to postgres via gcp Workload identity mapping
4. Map KSA for every gitlab service (like gcp-int-gitlab-webservice) with GSA in Workload identity mapping

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