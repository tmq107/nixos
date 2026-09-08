#!/usr/bin/env bash
set -euo pipefail

TPM_DIR="${HOME}/.tmux/plugins/tpm"
TMUX_CONF="${HOME}/.config/tmux/tmux.conf"

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is not installed"
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "Error: tmux is not installed"
  exit 1
fi

mkdir -p "${HOME}/.tmux/plugins"
mkdir -p "${HOME}/.config/tmux"

if [ ! -d "$TPM_DIR" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "TPM already installed"
fi

if [ -f "$TMUX_CONF" ]; then
  echo "Reloading tmux config..."
  tmux source-file "$TMUX_CONF" 2>/dev/null || true
else
  echo "Warning: $TMUX_CONF not found"
fi

echo "Installing tmux plugins..."
"$TPM_DIR/bin/install_plugins"

echo "Done"
