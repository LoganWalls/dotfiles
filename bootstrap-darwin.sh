#!/usr/bin/env bash
set -euo pipefail

nix --extra-experimental-features "nix-command flakes" run nixpkgs#nh -- darwin switch .
