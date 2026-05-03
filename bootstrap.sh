#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
    Darwin)
        subcommand="darwin"
        ;;
    Linux)
        if [ -e /etc/NIXOS ] || [ -e /etc/nixos ]; then
            subcommand="os"
        else
            echo "Unsupported Linux system: NixOS not detected" >&2
            exit 1
        fi
        ;;
    *)
        echo "Unsupported system: $(uname -s)" >&2
        exit 1
        ;;
esac

nix --extra-experimental-features "nix-command flakes" run nixpkgs#nh -- "$subcommand" switch .
