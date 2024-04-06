final: prev: let
  pkgs = final;
  inherit (pkgs) fetchpatch fetchurl callPackage;
  emacs-plus-commit-hash = "e2869844e8f5e7995e25071cbcbe69f26f707109";
  icon = fetchurl {
    url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/${emacs-plus-commit-hash}/icons/savchenkovaleriy-big-sur-3d.icns";
    sha256 = "sha256-ENBTIMwT39tP8MeOJdktT8tHXZMa52LUnn8IlL5sMJ8=";
  };
in {
  my-emacs = let
    emacs = pkgs.emacs-pgtk;
    patched-emacs =
      if pkgs.stdenv.isDarwin
      then
        emacs.overrideAttrs
        (old: {
          patches =
            (old.patches or [])
            ++ [
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
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/${emacs-plus-commit-hash}/patches/emacs-30/round-undecorated-frame.patch";
                sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
              })
              # Make emacs aware of OS-level light/dark mode
              (fetchpatch {
                url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/${emacs-plus-commit-hash}/patches/emacs-30/system-appearance.patch";
                sha256 = "sha256-3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=";
              })
            ];

          # Replace the app icon
          postFixup =
            old.postFixup
            + ''
              cp ${icon} "$out/Applications/Emacs.app/Contents/Resources/Emacs.icns"
            '';
        })
      else emacs;
  in
    pkgs.emacsWithPackagesFromUsePackage {
      package = patched-emacs;
      config = ../config/emacs/init.el;
      # Don't copy the config file. I symlink it with home-manager
      defaultInitFile = false;
      alwaysEnsure = true;
      extraEmacsPackages = epkgs:
        with epkgs; [
          treesit-grammars.with-all-grammars
        ];
      override = final: prev: {
        # Include fonts with all-the-icons
        all-the-icons = prev.melpaPackages.all-the-icons.overrideAttrs (old: {
          propagatedBuildInputs = old.propagatedBuildInputs ++ [pkgs.emacs-all-the-icons-fonts];
        });
      };
    };
}
