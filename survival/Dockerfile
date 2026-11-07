ARG R_VERSION=4.6.2
FROM ghcr.io/r-hub/r-minimal/r-minimal:${R_VERSION}

RUN installr -d -t gfortran survival \
    && R -q -e "library(survival)"