# Minimal R images

Small R images extending [`ghcr.io/r-hub/r-minimal/r-minimal`](https://github.com/r-hub/r-minimal) at R versions `4.5.3` or `4.6.2`. These images do not build R; they add only the requested CRAN packages and, for `nanonext`, the Alpine libraries needed to build and load it.

## Images

| Image | R packages |
| --- | --- |
| `ghcr.io/<owner>/r-survival` | `survival` |
| `ghcr.io/<owner>/r-nanonext` | `nanonext` |

Every image supports `linux/amd64` and `linux/arm64` and is published with `4.5.3` and `4.6.2` tags, plus commit-specific tags in the form `<sha>-4.5.3` and `<sha>-4.6.2`. The `latest` and plain commit SHA tags refer to the `4.6.2` build. Replace `<owner>` with the lowercase GitHub account or organization that owns this repository.

### Image sizes

Exact sizes depend on the upstream base image, resolved package versions, architecture, and registry compression. Each successful push reports sizes for every R version and architecture in the GitHub Actions run summary. The reported byte count is Docker's local image size (the sum of uncompressed image layers), not the compressed download size.

To inspect the local size of a pulled image:

```sh
OWNER=your-github-owner
docker pull --platform linux/amd64 "ghcr.io/$OWNER/r-survival:4.6.2"
docker image inspect "ghcr.io/$OWNER/r-survival:4.6.2" --format '{{.Size}} bytes'
```

Change `linux/amd64` to `linux/arm64` to inspect the other image variant.

## Build locally

Build either supported R version and run the package load check:

```sh
docker build --build-arg R_VERSION=4.5.3 -t r-survival:4.5.3 -f survival/Dockerfile survival
docker run --rm r-survival:4.5.3 R -q -e 'library(survival)'

docker build --build-arg R_VERSION=4.6.2 -t r-survival:4.6.2 -f survival/Dockerfile survival
docker run --rm r-survival:4.6.2 R -q -e 'library(survival)'
```

Run the local build and package-load checks for every image and R version with:

```sh
bash test/build-images.sh
```

To test a single combination, pass the package and R version:

```sh
bash test/build-images.sh nanonext 4.6.2
```

Docker must be running. Test images are tagged locally as `r-minimal-images/r-<package>:<version>` and are not pushed.

Run the package-load checks again against images that are already built with:

```sh
bash test/run-images.sh
bash test/run-images.sh nanonext 4.6.2
```

The `nanonext` Dockerfile runs its package load check during the build. To build and load both architectures or publish to GHCR, use Buildx:

```sh
OWNER=your-github-owner
docker buildx build --platform linux/amd64,linux/arm64 \
  --build-arg R_VERSION=4.5.3 \
  -t "ghcr.io/$OWNER/r-survival:4.5.3" \
  -t "ghcr.io/$OWNER/r-survival:your-commit-sha-4.5.3" \
  -f survival/Dockerfile --push survival
```

Repeat with `R_VERSION=4.6.2` and corresponding tags to publish the other version. GitHub Actions builds both versions of both images and publishes them on pushes to `main` and manual workflow dispatch. Pull requests build all variants for both platforms without publishing.

## Use an image

```sh
OWNER=your-github-owner
docker run --rm "ghcr.io/$OWNER/r-survival:4.6.2" \
  R -q -e 'library(survival); packageVersion("survival")'

docker run --rm "ghcr.io/$OWNER/r-nanonext:4.5.3" \
  R -q -e 'library(nanonext); packageVersion("nanonext")'
```

For reproducible deployments, use the version-specific or commit-specific tag. For example:

```sh
OWNER=your-github-owner
docker run --rm "ghcr.io/$OWNER/r-survival:your-commit-sha-4.5.3" R
```

## Package versions

Package versions are resolved from the CRAN repository configured by `r-minimal` at build time; they are not pinned in this repository. Query the versions included in a published image with `packageVersion()` as shown above. The R base version is selected explicitly as `4.5.3` or `4.6.2`; rebuilding can update Alpine and package versions within that upstream R image line.

## `nanonext` Alpine dependencies

The `nanonext` images keep the runtime packages `nng`, `libsodium`, and `mbedtls`. Their development packages (`nng-dev`, `libsodium-dev`, and `mbedtls-dev`) are added temporarily for compilation and removed after installation. R packages are installed with the `installr` tooling supplied by `r-minimal`.

## License

See <https://www.r-project.org/Licenses/> for the R licenses.

These Dockerfiles are licensed under the MIT License.
