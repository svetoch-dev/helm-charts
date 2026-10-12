#!/usr/bin/env bash
set -euo pipefail

CRDS_VERSION="0.1.0"
cd "$(dirname "$0")"
curl --fail --location --silent --show-error \
  "https://raw.githubusercontent.com/svetoch-dev/vedro/refs/tags/helm-v${CRDS_VERSION}/helm/controller/crds/vedro.yaml" \
  --output "${CRDS_VERSION}.vedro.yaml"

for old_crd in *.vedro.yaml; do
  if [[ "$old_crd" != "${CRDS_VERSION}.vedro.yaml" && -f "$old_crd" ]]; then
    rm -- "$old_crd"
  fi
done
