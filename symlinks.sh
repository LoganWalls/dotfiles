#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
ln -s "$SCRIPT_DIR/config" "${XDG_CONFIG_HOME:-$HOME/.config}"
