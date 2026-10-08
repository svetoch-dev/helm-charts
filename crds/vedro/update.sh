#!/usr/bin/env bash
set -euo pipefail

CRDS_VERSION="0.1.0"
cd "$(dirname "$0")"
curl --fail --location --silent --show-error \
  "https://raw.githubusercontent.com/svetoch-dev/vedro/refs/tags/helm-v${CRDS_VERSION}/helm/controller/crds/vedro.yaml" \
  --output "${CRDS_VERSION}.vedro.yaml"
