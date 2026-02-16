# syntax=docker/dockerfile:1

FROM debian:bookworm-slim AS builder

ARG GFATOOLS_VERSION=v0.5
ARG GFATOOLS_URL=https://github.com/lh3/gfatools/archive/refs/tags/v0.5.tar.gz
ARG GFATOOLS_SHA256=0653dc143c2224743afb6bb638da3465231ec0bb476c0d55e2eb6708ee105712

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gcc make zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN curl -fsSL "$GFATOOLS_URL" -o gfatools.tar.gz \
    && echo "$GFATOOLS_SHA256  gfatools.tar.gz" | sha256sum -c - \
    && tar -xzf gfatools.tar.gz

WORKDIR /src/gfatools-0.5
RUN make CFLAGS="-O2 -static" \
    && test -x gfatools \
    && cp gfatools /tmp/gfatools

FROM scratch
COPY --from=builder /tmp/gfatools /usr/local/bin/gfatools
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/gfatools"]
