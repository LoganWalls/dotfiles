{
  inputs,
  pkgs,
  ...
}: let
  packageGroups = import ../package-groups/default.nix {
    inherit inputs pkgs;
    homeDirectory =
      if pkgs.stdenv.isLinux
      then "/home/logan"
      else "/Users/logan";
  };
in
  inputs.flakey-profile.lib.mkProfile rec {
    inherit pkgs;

    # Specifies things to pin in the flake registry and in NIX_PATH.
    pinned = {nixpkgs = toString inputs.nixpkgs;};

    paths =
      packageGroups.neovim
      ++ packageGroups.shell
      ++ packageGroups.fonts
      ++ (with pkgs; [
        age # encryption
        ffmpeg # work images, audio, and video
        imagemagick # work with images
        librsvg # allows rasterizing SVGs
        macchina # more performant neofetch alternative
        zathura # pdf viewer
      ]);
  }
