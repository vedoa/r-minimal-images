#!/usr/bin/env bash
set -euo pipefail

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
  for r_version in "${versions[@]}"; do
    image="r-minimal-images/r-${package}:${r_version}"

    if ! docker image inspect "$image" >/dev/null 2>&1; then
      printf 'Local image not found: %s. Build it with test/build-images.sh first.\n' \
        "$image" >&2
      exit 1
    fi

    printf '\nChecking library(%s) in %s\n' "$package" "$image"
    docker run --rm "$image" R -q -e "library(${package})"
  done
done
