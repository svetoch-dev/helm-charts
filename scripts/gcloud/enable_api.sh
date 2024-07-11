#!/bin/bash
[[ -z $* ]] && echo "project not set" && return 1
project=$1
gcloud auth application-default set-quota-project $project
#export CLOUDSDK_CORE_PROJECT=$project
gcloud services enable compute.googleapis.com --project $project
