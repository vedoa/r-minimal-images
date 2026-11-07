#!/usr/bin/env bash
set -euo pipefail

: "${IMAGE:?IMAGE must be set}"
: "${GITHUB_STEP_SUMMARY:?GITHUB_STEP_SUMMARY must be set}"

printf '| Image | Platform | Size |\n| --- | --- | ---: |\n' >> "$GITHUB_STEP_SUMMARY"

for platform in linux/amd64 linux/arm64; do
  docker pull --platform "$platform" "$IMAGE"
  size=$(docker image inspect "$IMAGE" --format '{{.Size}}')
  human_size=$(numfmt --to=iec-i --suffix=B "$size")
  printf '| `%s` | %s | %s bytes (%s) |\n' \
    "$IMAGE" "$platform" "$size" "$human_size" >> "$GITHUB_STEP_SUMMARY"
done