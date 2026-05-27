#!/usr/bin/env sh
set -eu

PUID="${PUID:-0}"
PGID="${PGID:-0}"

if [ "${TZ:-}" != "" ] && [ -f "/usr/share/zoneinfo/${TZ}" ]; then
  ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
  echo "${TZ}" > /etc/timezone
fi

# Configuration runtime, pour éviter de cuire les secrets dans l'image.
configure_args=""

if [ "${CRONITOR_API_KEY:-}" != "" ]; then
  configure_args="$configure_args --api-key ${CRONITOR_API_KEY}"
fi

if [ "${CRONITOR_PING_API_KEY:-}" != "" ]; then
  configure_args="$configure_args --ping-api-key ${CRONITOR_PING_API_KEY}"
fi

if [ "${CRONITOR_HOSTNAME:-}" != "" ]; then
  configure_args="$configure_args --hostname ${CRONITOR_HOSTNAME}"
fi

if [ "${CRONITOR_DASH_USERNAME:-}" != "" ]; then
  configure_args="$configure_args --dash-username ${CRONITOR_DASH_USERNAME}"
fi

if [ "${CRONITOR_DASH_PASSWORD:-}" != "" ]; then
  configure_args="$configure_args --dash-password ${CRONITOR_DASH_PASSWORD}"
fi

if [ "${configure_args}" != "" ]; then
  # shellcheck disable=SC2086
  cronitor configure ${configure_args}
fi

if [ "${PUID}" != "0" ] || [ "${PGID}" != "0" ]; then
  groupmod -o -g "${PGID}" cronitor 2>/dev/null || groupadd -o -g "${PGID}" cronitor
  usermod -o -u "${PUID}" -g "${PGID}" cronitor 2>/dev/null || useradd -o -u "${PUID}" -g "${PGID}" -d /config -s /bin/sh cronitor
  chown -R "${PUID}:${PGID}" /etc/cronitor /var/spool/cron/crontabs 2>/dev/null || true
  exec su-exec "${PUID}:${PGID}" cronitor "$@"
fi

exec cronitor "$@"
