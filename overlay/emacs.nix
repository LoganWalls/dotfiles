final: prev: let
  pkgs = final;
  inherit (pkgs) fetchpatch fetchurl callPackage;
  # icon = ../programs/emacs/macos-uuicon.png;
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
            ++ [
              # Fix OS window role so that yabai can pick up emacs
              (fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
                sha256 = "0c41rgpi19vr9ai740g09lka3nkjk48ppqyqdnncjrkfgvm2710z";
              })
              # Use poll instead of select to get file descriptors
              (fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/poll.patch";
                sha256 = "0j26n6yma4n5wh4klikza6bjnzrmz6zihgcsdx36pn3vbfnaqbh5";
              })
              # Enable rounded window with no decoration
              (fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/round-undecorated-frame.patch";
                sha256 = "111i0r3ahs0f52z15aaa3chlq7ardqnzpwp8r57kfsmnmg6c2nhf";
              })
              # Make emacs aware of OS-level light/dark mode
              (fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
                sha256 = "14ndp2fqqc95s70fwhpxq58y8qqj4gzvvffp77snm2xk76c1bvnn";
              })
            ];

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
