# Agent Notification

## WSL 

Require: https://github.com/stuartleeks/wsl-notify-send

```shell ~/.local/bin/notify-send
#!/usr/bin/env bash
set -euo pipefail

# Herdr calls: notify-send -- TITLE BODY
if [[ "${1:-}" == "--" ]]; then
    shift
fi

title="${1:-Herdr}"

if [[ $# -gt 0 ]]; then
    shift
fi

body="$*"

if [[ -z "$body" ]]; then
    body="$title"
fi

# Avoid wsl-notify-send UTF-8 mojibake.
title="${title//·/ - }"
body="${body//·/ - }"

exec /mnt/c/Users/<user>/Downloads/wsl-notify-send/wsl-notify-send.exe \
    --appId "Herdr" \
    --category "$title" \
    "$body"

```
