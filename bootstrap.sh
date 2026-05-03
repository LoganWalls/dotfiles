#!/usr/bin/env bash
set -euo pipefail

hostname="${1:-}"
flake="."
if [ -n "$hostname" ]; then
    flake=".#$hostname"
fi

export NIX_CONFIG="extra-experimental-features = nix-command flakes"

case "$(uname -s)" in
    Darwin)
        nix run nixpkgs#nh -- darwin switch "$flake"
        ;;
    Linux)
        if [ ! -e /etc/NIXOS ] && [ ! -e /etc/nixos ]; then
            echo "Unsupported Linux system: NixOS not detected" >&2
            exit 1
        fi
        sudo nixos-rebuild switch --flake "$flake" --install-bootloader
        ;;
    *)
        echo "Unsupported system: $(uname -s)" >&2
        exit 1
        ;;
esac
