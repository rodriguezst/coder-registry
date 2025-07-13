#!/usr/bin/env bash
set -euo pipefail

error() { printf "💀 ERROR: %s\n" "$@"; exit 1; }

: "${PORT?Must set PORT}"    # Port for web UI
: "${SELKIES_VERSION:=latest}"

SELKIES_DIR="/opt/selkies-gstreamer-$SELKIES_VERSION"
if [[ ! -d "$SELKIES_DIR" ]]; then
  apt-get update -yq && apt-get install -yq --no-install-recommends \
    ca-certificates curl jq tar gzip libpulse0 libegl1-mesa xvfb pulseaudio
  mkdir -p "$SELKIES_DIR"
  SELKIES_VERSION_RESOLVED=$SELKIES_VERSION
  if [[ "$SELKIES_VERSION" == "latest" ]]; then
    SELKIES_VERSION_RESOLVED=$(curl -fsSL "https://api.github.com/repos/selkies-project/selkies-gstreamer/releases/latest" | jq -r .tag_name | sed 's/^v//')
  fi
  curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION_RESOLVED}/selkies-gstreamer-portable-v${SELKIES_VERSION_RESOLVED}_amd64.tar.gz" \
      | tar -xzf - -C "$SELKIES_DIR"
fi

export DISPLAY=":0"
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR:-/tmp}/pulse/native"

BASIC_USER="${USER:-coder}"
BASIC_PASS="mypasswd"

set +e
"$SELKIES_DIR/selkies-gstreamer-run" \
    --addr=0.0.0.0 \
    --port="$PORT" \
    --enable_https=false \
    --basic_auth_user="$BASIC_USER" \
    --basic_auth_password="$BASIC_PASS" \
    --encoder=x264enc \
    > /tmp/selkies_desktop.log 2>&1 &
sleep 3
RETVAL=$(pgrep -f selkies-gstreamer-run > /dev/null && echo 0 || echo 1)
set -e
if [[ $RETVAL -ne 0 ]]; then
  echo "ERROR: Failed to start Selkies server"
  cat /tmp/selkies_desktop.log || true
  exit 1
fi
printf "🚀 Selkies Desktop streaming started successfully!\n"
