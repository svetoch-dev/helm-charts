#!/bin/bash
[[ -z $* ]] && echo "project not set" && return 1
project=$1
#gcloud auth application-default set-quota-project --project $project-internal
#export CLOUDSDK_CORE_PROJECT=$project-internal
gcloud storage buckets create gs://$project-tf-state --location=EU --default-storage-class=STANDARD --pap --no-uniform-bucket-level-access --project $project-internal
gcloud storage buckets update gs://$project-tf-state --versioning --project $project-internal
gcloud storage buckets update gs://$project-tf-state --lifecycle-file=./lifecycle.json --project $project-internal
gcloud services enable compute.googleapis.com --project $project-internal
