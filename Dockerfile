# syntax=docker/dockerfile:1
# Compatibility-first template for gfatools.
# Installs package from Bioconda and copies the full conda runtime to avoid missing libs/interpreters.

FROM mambaorg/micromamba:2.0.5-debian12-slim AS builder

RUN micromamba install -y -n base -c conda-forge -c bioconda \
    gfatools \
    setuptools \
    && micromamba clean --all --yes

# Resolve a runnable command for this package.
# Prefer exact match, then underscore variant, then prefix match.
RUN set -eux; \
    BIN=""; \
    if [ -x "/opt/conda/bin/gfatools" ]; then BIN="/opt/conda/bin/gfatools"; fi; \
    if [ -z "$BIN" ]; then CAND="/opt/conda/bin/$(echo gfatools | tr '-' '_')"; [ -x "$CAND" ] && BIN="$CAND" || true; fi; \
    if [ -z "$BIN" ]; then BIN="$(find /opt/conda/bin -maxdepth 1 -type f -perm -111 -name 'gfatools*' | head -n1 || true)"; fi; \
    test -n "$BIN"; \
    printf '%s\n' "$BIN" > /tmp/tool-entry-path

FROM mambaorg/micromamba:2.0.5-debian12-slim

COPY --from=builder /opt/conda /opt/conda
COPY --from=builder /tmp/tool-entry-path /tmp/tool-entry-path

USER root
ENV PATH="/opt/conda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/conda/lib:/opt/conda/lib64"
RUN set -eux; \
    BIN="$(cat /tmp/tool-entry-path)"; \
    { \
      echo '#!/usr/bin/env bash'; \
      echo 'set -euo pipefail'; \
      echo "BIN=\"$BIN\""; \
      echo 'if [ "${1:-}" = "--help" ]; then'; \
      echo '  last_ec=1'; \
      echo '  last_tmp=""'; \
      echo '  for candidate in "--help" "-h" "help" ""; do'; \
      echo '    tmp="$(mktemp)"'; \
      echo '    set +e'; \
      echo '    if [ -n "$candidate" ]; then'; \
      echo '      "$BIN" "$candidate" >"$tmp" 2>&1'; \
      echo '    else'; \
      echo '      "$BIN" >"$tmp" 2>&1'; \
      echo '    fi'; \
      echo '    ec=$?'; \
      echo '    set -e'; \
      echo '    if [ "$ec" -eq 0 ]; then'; \
      echo '      cat "$tmp"'; \
      echo '      rm -f "$tmp"'; \
      echo '      exit 0'; \
      echo '    fi'; \
      echo '    if grep -Eiq "(usage|help|options|version|available|commands?)" "$tmp"; then'; \
      echo '      cat "$tmp"'; \
      echo '      rm -f "$tmp"'; \
      echo '      exit 0'; \
      echo '    fi'; \
      echo '    last_ec="$ec"'; \
      echo '    last_tmp="$tmp"'; \
      echo '  done'; \
      echo '  if [ -n "$last_tmp" ]; then'; \
      echo '    cat "$last_tmp" >&2'; \
      echo '    rm -f "$last_tmp"'; \
      echo '  fi'; \
      echo '  exit "$last_ec"'; \
      echo 'fi'; \
      echo 'exec "$BIN" "$@"'; \
    } > /usr/local/bin/gfatools
RUN chmod +x /usr/local/bin/gfatools && rm -f /tmp/tool-entry-path
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/gfatools"]
