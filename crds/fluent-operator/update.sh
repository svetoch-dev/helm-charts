#!/bin/bash
set -e
CRDS_VERSION="3.4.0"

for file in `ls | grep -E 'fluentd.*yml|fluentd.*yaml'`
do
  CRDS_OLD_VERSION=$(echo $file | awk -F'.' '{print $1"."$2"."$3}')
  CRDS_NAME=$(echo $file | grep -v "$CRDS_VERSION" | sed "s/$CRDS_OLD_VERSION\.//g")
  echo "Downloading ${CRDS_VERSION}.${CRDS_NAME}"
  curl -L -s -o "${CRDS_VERSION}.${CRDS_NAME}" https://raw.githubusercontent.com/fluent/helm-charts/refs/tags/fluent-operator-${CRDS_VERSION}/charts/fluent-operator/charts/fluentd-crds/crds/${CRDS_NAME}
  echo "Removing ${CRDS_OLD_VERSION}.${CRDS_NAME}"
  rm "${CRDS_OLD_VERSION}.${CRDS_NAME}"
done

for file in `ls | grep -E 'fluentbit.*yml|fluentbit.*yaml'`
do
  CRDS_OLD_VERSION=$(echo $file | awk -F'.' '{print $1"."$2"."$3}')
  CRDS_NAME=$(echo $file | grep -v "$CRDS_VERSION" | sed "s/$CRDS_OLD_VERSION\.//g")
  echo "Downloading ${CRDS_VERSION}.${CRDS_NAME}"
  curl -L -s -o "${CRDS_VERSION}.${CRDS_NAME}" https://raw.githubusercontent.com/fluent/helm-charts/refs/tags/fluent-operator-${CRDS_VERSION}/charts/fluent-operator/charts/fluent-bit-crds/crds/${CRDS_NAME}
  echo "Removing ${CRDS_OLD_VERSION}.${CRDS_NAME}"
  rm "${CRDS_OLD_VERSION}.${CRDS_NAME}"
done
