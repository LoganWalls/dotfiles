#!/usr/bin/env bash
set -euo pipefail

# Remove previous fonts
chmod -R u+w "$HOME/Library/Fonts/Nix"
rm -rf "$HOME/Library/Fonts/Nix"

# Copy new fonts (must copy; symlinks don't work)
cp -LR "$HOME/.nix-profile/share/fonts" "$HOME/Library/Fonts/Nix"
chown -R "$USER" "$HOME/Library/Fonts/Nix"
chmod -R u+r "$HOME/Library/Fonts/Nix"

# Restart fontd so that apps will recognize the new fonts
launchctl kickstart -k gui/$(id -u)/com.apple.fontd 2> /dev/null || true
