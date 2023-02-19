final: prev: let
  pkgs = final;
  inherit (pkgs) fetchpatch fetchurl callPackage;
  icon = fetchurl {
    url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/6d4b8346773907e42efacbcf5aac0b27b79cc3b9/icons/memeplex-slim.icns";
    sha256 = "0g025b4a4c47dp46zkc7rf3wgkk8b9bf8glisz7dsms3zzwyckcl";
  };
in {
  my-emacs = pkgs.emacsWithPackagesFromUsePackage rec {
    # Your Emacs config file. Org mode babel files are also
    # supported.
    # NB: Config files cannot contain unicode characters, since
    #     they're being parsed in nix, which lacks unicode
    #     support.
    # config = ./emacs.org;
    config = ../programs/emacs/emacs.el;

    # Whether to include your config as a default init file.
    # If being bool, the value of config is used.
    # Its value can also be a derivation like this if you want to do some
    # substitution:
    #   defaultInitFile = pkgs.substituteAll {
    #     name = "default.el";
    #     src = ./emacs.el;
    #     inherit (config.xdg) configHome dataHome;
    #   };
    defaultInitFile = true;

    package =
      if pkgs.stdenv.isDarwin
      then
        pkgs.emacsPgtk.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ (let
              emacs-plus-commit-hash = "6d4b8346773907e42efacbcf5aac0b27b79cc3b9";
            in [
              # Fix OS window role so that yabai can pick up emacs
              (fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/${emacs-plus-commit-hash}/patches/emacs-28/fix-window-role.patch";
                sha256 = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
              })
              # Use poll instead of select to get file descriptors
              (fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/${emacs-plus-commit-hash}/patches/emacs-29/poll.patch";
                sha256 = "sha256-jN9MlD8/ZrnLuP2/HUXXEVVd6A+aRZNYFdZF8ReJGfY=";
              })
              # Enable rounded window with no decoration
              (fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/${emacs-plus-commit-hash}/patches/emacs-29/round-undecorated-frame.patch";
                sha256 = "sha256-qPenMhtRGtL9a0BvGnPF4G1+2AJ1Qylgn/lUM8J2CVI=";
              })
              # Make emacs aware of OS-level light/dark mode
              (fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/${emacs-plus-commit-hash}/patches/emacs-28/system-appearance.patch";
                sha256 = "sha256-oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
              })
            ]);

          # Replace the app icon
          postFixup =
            old.postFixup
            + ''
              cp ${icon} "$out/Applications/Emacs.app/Contents/Resources/Emacs.icns"
            '';
        })
      else pkgs.emacsPgtk;

    # By default emacsWithPackagesFromUsePackage will only pull in
    # packages with `:ensure`, `:ensure t` or `:ensure <package name>`.
    # Setting `alwaysEnsure` to `true` emulates `use-package-always-ensure`
    # and pulls in all use-package references not explicitly disabled via
    # `:ensure nil` or `:disabled`.
    # Note that this is NOT recommended unless you've actually set
    # `use-package-always-ensure` to `t` in your config.
    alwaysEnsure = true;

    # For Org mode babel files, by default only code blocks with
    # `:tangle yes` are considered. Setting `alwaysTangle` to `true`
    # will include all code blocks missing the `:tangle` argument,
    # defaulting it to `yes`.
    # Note that this is NOT recommended unless you have something like
    # `#+PROPERTY: header-args:emacs-lisp :tangle yes` in your config,
    # which defaults `:tangle` to `yes`.
    # alwaysTangle = true;

    # Optionally provide extra packages not in the configuration file.
    extraEmacsPackages = epkgs: [
      # TODO: remove this once use-package is included with base emacs
      epkgs.use-package
    ];

    # Optionally override derivations.
    override = epkgs:
      epkgs
      // {
        lambda-themes = callPackage ../pkgs/emacs/lambda-themes.nix {
          emacs = package;
          inherit (pkgs) lib fetchFromGitHub;
          inherit (epkgs) trivialBuild;
        };
        lambda-line = callPackage ../pkgs/emacs/lambda-line.nix {
          emacs = package;
          inherit (pkgs) lib fetchFromGitHub;
          inherit (epkgs) trivialBuild all-the-icons;
        };
      };
  };
}
