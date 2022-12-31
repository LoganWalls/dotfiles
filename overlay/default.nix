# This file defines two overlays and composes them
{inputs, ...}: let
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev:
    import ../pkgs {
      inherit inputs;
      pkgs = final;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    yabai = prev.yabai.overrideAttrs (old: rec {
      version = "5.0.2";
      src = final.fetchzip {
        url = "https://github.com/koekeishiya/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
        hash = "sha256-wL6N2+mfFISrOFn4zaCQI+oH6ixwUMRKRi1dAOigBro=";
      };
    });
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };
in
  inputs.nixpkgs.lib.composeManyExtensions [
    additions
    modifications
    (import ./nix-community-emacs-overlay.nix)
    (import ./emacs.nix)
    (import ./python.nix)
  ]
