#!/usr/bin/env bash
set -euo pipefail

hostname="${1:-}"
flake="."
if [ -n "$hostname" ]; then
    flake=".#$hostname"
fi

case "$(uname -s)" in
    Darwin)
        subcommand=(darwin switch "$flake")
        ;;
    Linux)
        if [ ! -e /etc/NIXOS ] && [ ! -e /etc/nixos ]; then
            echo "Unsupported Linux system: NixOS not detected" >&2
            exit 1
        fi
        subcommand=(os switch --install-bootloader "$flake")
        ;;
    *)
        echo "Unsupported system: $(uname -s)" >&2
        exit 1
        ;;
esac

export NIX_CONFIG="extra-experimental-features = nix-command flakes"
nix run nixpkgs#nh -- "${subcommand[@]}"
