# syntax=docker/dockerfile:1.7
FROM alpine:3.20

ARG VERSION=latest
ARG TARGETARCH
ARG TARGETVARIANT

LABEL org.opencontainers.image.title="Cronitor CLI"
LABEL org.opencontainers.image.description="Unofficial container image for cronitorio/cronitor-cli"
LABEL org.opencontainers.image.source="https://github.com/cronitorio/cronitor-cli"

RUN apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      dcron \
      shadow \
      su-exec \
      tzdata

RUN set -eux; \
    case "${TARGETARCH}${TARGETVARIANT:-}" in \
      amd64) CRONITOR_ARCH="amd64" ;; \
      arm64*) CRONITOR_ARCH="arm64" ;; \
      armv7|arm) CRONITOR_ARCH="arm" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}${TARGETVARIANT:-}" >&2; exit 1 ;; \
    esac; \
    if [ "${VERSION}" = "latest" ]; then \
      VERSION="$(curl -fsSL https://api.github.com/repos/cronitorio/cronitor-cli/releases/latest | sed -n 's/.*"tag_name": *"\\([^"]*\\)".*/\\1/p' | head -n1)"; \
    fi; \
    archive="linux_${CRONITOR_ARCH}.tar.gz"; \
    base_url="https://github.com/cronitorio/cronitor-cli/releases/download/${VERSION}"; \
    curl -fsSLo "/tmp/${archive}" "${base_url}/${archive}"; \
    curl -fsSLo "/tmp/${archive}.sha256" "${base_url}/${archive}.sha256"; \
    expected="$(awk '{print $1}' "/tmp/${archive}.sha256")"; \
    actual="$(sha256sum "/tmp/${archive}" | awk '{print $1}')"; \
    test "${actual}" = "${expected}"; \
    tar -xzf "/tmp/${archive}" -C /usr/local/bin cronitor; \
    chmod +x /usr/local/bin/cronitor; \
    rm -f "/tmp/${archive}" "/tmp/${archive}.sha256"; \
    cronitor --version || true

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/etc/cronitor", "/var/spool/cron/crontabs"]
EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dash", "--port", "9000"]
