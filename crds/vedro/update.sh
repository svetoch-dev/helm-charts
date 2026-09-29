#!/usr/bin/env bash
set -euo pipefail

# Keep this tag aligned with the Vedro chart and controller release.
VEDRO_TAG="helm-v0.1.0"
CRDS_VERSION="v0.1.0"
CRDS=(
  vedro.svetoch.dev_bucketaccesses.yaml
  vedro.svetoch.dev_buckets.yaml
  vedro.svetoch.dev_cloudprincipalauths.yaml
  vedro.svetoch.dev_cloudprincipals.yaml
  vedro.svetoch.dev_providerconfigs.yaml
)

cd "$(dirname "$0")"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

for crd in "${CRDS[@]}"; do
  curl --fail --location --silent --show-error \
    "https://raw.githubusercontent.com/svetoch-dev/vedro/refs/tags/${VEDRO_TAG}/config/crd/bases/${crd}" \
    --output "${tmp_dir}/${crd}"
  grep -q '^kind: CustomResourceDefinition$' "${tmp_dir}/${crd}"
done

for crd in "${CRDS[@]}"; do
  cp "${tmp_dir}/${crd}" "${CRDS_VERSION}.${crd}"
  for old_crd in *."${crd}"; do
    if [[ "${old_crd}" != "${CRDS_VERSION}.${crd}" && -f "${old_crd}" ]]; then
      rm -- "${old_crd}"
    fi
  done
done
