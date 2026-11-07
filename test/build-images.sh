#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_filter="${1:-all}"
version_filter="${2:-all}"

case "$package_filter" in
  all) packages=(survival nanonext) ;;
  survival|nanonext) packages=("$package_filter") ;;
  *) printf 'Usage: %s [all|survival|nanonext] [all|4.5.3|4.6.2]\n' "$0" >&2; exit 2 ;;
esac

case "$version_filter" in
  all) versions=(4.5.3 4.6.2) ;;
  4.5.3|4.6.2) versions=("$version_filter") ;;
  *) printf 'Usage: %s [all|survival|nanonext] [all|4.5.3|4.6.2]\n' "$0" >&2; exit 2 ;;
esac

for package in "${packages[@]}"; do
  image_package="r-${package}"

  for r_version in "${versions[@]}"; do
    image="r-minimal-images/${image_package}:${r_version}"

    printf '\nBuilding %s for R %s\n' "$image_package" "$r_version"
    docker build \
      --build-arg "R_VERSION=${r_version}" \
      --file "${repo_root}/${package}/Dockerfile" \
      --tag "$image" \
      "${repo_root}/${package}"

    printf 'Checking library(%s) in %s\n' "$package" "$image"
    docker run --rm "$image" R -q -e "library(${package})"
  done
done