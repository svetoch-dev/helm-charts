Which secrets are important to create by yourself:
1. Redis secret  (redis-gitlab):
    ```bash
    kubectl create secret generic redis-gitlab   --namespace gitlab   --from-literal=password="$(openssl rand -base64 24)"   --from-literal=redis-password="$(openssl rand -base64 24)"
    ```
2. Object storage secret (gitlab-object-storage):
   1. object_storage.yaml
    ```yaml
    provider: Google
    google_project: kitchenhub-internal
    google_application_default: true
    ```
   2. create
    ```bash
    kubectl create secret generic gitlab-object-storage   --namespace gitlab   --from-file=connection=object_storage.yaml
    ```