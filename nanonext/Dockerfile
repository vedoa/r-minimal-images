ARG R_VERSION=4.6.2
FROM ghcr.io/r-hub/r-minimal/r-minimal:${R_VERSION}

RUN apk add --no-cache nng libsodium mbedtls \
    && apk add --no-cache --virtual .nanonext-build-deps \
        nng-dev libsodium-dev mbedtls-dev \
    && installr -d nanonext \
    && R -q -e "library(nanonext)" \
    && apk del .nanonext-build-deps