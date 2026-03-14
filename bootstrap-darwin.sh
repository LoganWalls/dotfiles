#!/usr/bin/env bash
set -euo pipefail

sudo -H nix --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake .
