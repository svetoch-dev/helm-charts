# Scripts
Various scripts

## bucket_initial.sh
Script that creates first gcloud storage bucket, to be able to execute 'terraform init' in internal env

### Usage

```
./bucket_initial.sh your_project_name
```

#### description

* `your_project_name` - Name of your project, for example 'sparkperps' or 'dexfinance'.

This script dependents on file lifecycle.json.

 After executing this script, bucket your_project_name-internal will be created in internal environment, and gcloud api service compute.googleapis.com enabled.

### Examples

```
$ ./bucket_initial.sh sparkperps
$ ./bucket_initial.sh dexfinance
```


## enable_api.sh
Script that enables api service compute.googleapis.com, to be able to execute 'terraform init'

### Usage

```
./enable_api.sh your_project_name-environment
```

#### description

* `your_project_name-environment` - Name of your environment in the project, for example 'sparkperps-production' or 'dexfinance-development'.

 After executing this script, gcloud api service compute.googleapis.com enabled.

### Examples

```
$ ./enable_api.sh sparkperps-production
$ ./enable_api.sh dexfinance-development
```


##  GKE_upgrade.sh
Script that upgrades k8s clusters (GKE)

### Usage

```
./GKE_upgrade.sh  your_project_name-environment
 or
./GKE_upgrade.sh
 to use a set project
```

#### description

* `your_project_name-environment` - Name of your environment in the project, for example 'sparkperps-production' or 'dexfinance-development'.

 During script execution, postgres pdb resources are deleted. the postgres pod is transferred to a new node and pdb resources are re-created, if the postgres replica was moved first, then it is necessary to manually delete postgres pdb resources during script execution.

###### warning

```
Attention! The gcloud cli commands cannot delete the node on which the patroni master is located, so when the process starts upgrading the node on which the patroni master is located.
```

### Examples

```
$ ./enable_api.sh
$ ./enable_api.sh  sparkperps-production
$ ./enable_api.sh  dexfinance-development
```
