#!/bin/bash
set -e
CRDS_VERSION="v0.25.0"

for file in `ls | grep -E 'yml|yaml'`
do
  CRDS_OLD_VERSION=$(echo $file | awk -F'.' '{print $1"."$2"."$3}')
  CRDS_NAME=$(echo $file | grep -v "$CRDS_VERSION" | sed "s/$CRDS_OLD_VERSION\.//g")
  echo "Downloading ${CRDS_VERSION}.${CRDS_NAME}"
  curl -L -s -o "${CRDS_VERSION}.${CRDS_NAME}" https://raw.githubusercontent.com/OT-CONTAINER-KIT/redis-operator/refs/tags/${CRDS_VERSION}/charts/redis-operator/crds/${CRDS_NAME}
  echo "Removing ${CRDS_OLD_VERSION}.${CRDS_NAME}"
  rm "${CRDS_OLD_VERSION}.${CRDS_NAME}"
done
