{
  description = "My personal nix configurations";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    flakey-profile.url = "github:lf-/flakey-profile";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # SFMono font with NerdFont and Ligatures
    sf-mono-liga = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakey-profile,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  in rec {
    overlays = {
      default = import ./overlay {inherit inputs;};
      emacs = inputs.emacs-overlay.overlay;
      neovim = inputs.neovim-nightly-overlay.overlays.default;
    };

    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    devShells = forAllSystems (system: {
      default = legacyPackages.${system}.callPackage ./shell.nix {};
    });

    legacyPackages = forAllSystems (
      system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;

          # NOTE: Using `nixpkgs.config` in NixOS config won't work
          # Instead, set nixpkgs configs here
          # (https://nixos.org/manual/nixpkgs/stable/#idm140737322551056)
          config.allowUnfree = true;
        }
    );

    packages = forAllSystems (system: {
      profile = flakey-profile.lib.mkProfile rec {
        pkgs = legacyPackages."${system}";
        # Specifies things to pin in the flake registry and in NIX_PATH.
        pinned = {nixpkgs = toString nixpkgs;};

        paths = let
          homeDirectory =
            if pkgs.stdenv.isLinux
            then "/home/logan"
            else "/Users/logan";
        in
          with pkgs; [
            git

            ### GUI Apps
            wezterm
            (nushell.overrideAttrs (old: {
              # Override forces nushell to use XDG paths (defaults to Application Support on macOS)
              buildInputs = old.buildInputs ++ [makeWrapper];
              postInstall =
                old.postInstall
                or ""
                + ''
                  wrapProgram "$out/bin/nu" --set XDG_CONFIG_HOME "${homeDirectory}/.config"
                '';
            }))
            nushellPlugins.skim
            (neovim.overrideAttrs (old: {
              propagatedBuildInputs =
                (old.propagatedBuildInputs or [])
                ++ [
                  pkgs.stdenv.cc.cc # C compiler for tree-sitter grammars
                ];
            }))
            starship
            carapace
            direnv
            nix-direnv
            zoxide

            ### Shell tools
            age # encryption
            btop # system activity monitor
            bat # cat with highlighting
            bat-extras.batman # use bat to highlight manpages
            coreutils-prefixed # for compat with emacs
            eza # modern ls
            delta # modern diff
            fd # modern find
            flavours # base24 colorscheme management
            sd # modern sed
            ripgrep # modern grep
            just # command runner
            ugrep # faster grep with backward-compatible interface
            tealdeer # tldr for manpages
            macchina # more performant neofetch alternative
            # mosh # nice ssh sessions
            gitui # a nice git TUI
            vivid # ls_colors
            xclip # work with the system clipboards

            ### File format-specific tools
            jq # work with json files
            xsv # work with (c/t)sv files
            imagemagick # work with images
            ffmpeg # work images, audio, and video
            librsvg # allows rasterizing SVGs

            ##### Language-specific
            ### Shell
            shellcheck # linter
            shfmt # formatter

            ### Nix
            nil # language server
            nix-direnv # nix intergration for direnv
            alejandra # black-inspired formatting
            statix # linter

            ### C
            cmake

            ### Python
            uv # python package / env manager
            (python3.withPackages (ps: with ps; [ipython])) # base interpreter
            pyright # language server for static type analysis
            ruff-lsp # language server for everything else

            ### TOML
            taplo

            ### Lua
            lua-language-server
            stylua # formatter

            ### Docker
            nodePackages.dockerfile-language-server-nodejs

            ### Web
            nodePackages.vscode-langservers-extracted
            nodePackages.typescript
            nodePackages.typescript-language-server
            nodePackages.prettier # formatter

            ### Tex
            # texlive.combined.scheme-full # tex distribution
            # texlab # language server for tex

            ### Typst
            typst
            tinymist # language server
            typstfmt
            zathura # pdf viewer

            ### Other
            buf-language-server # protobuf

            ### Prose / writing
            vale # "linter" for prose

            ### Fonts
            (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Overpass" "NerdFontsSymbolsOnly"];})
            apple-fonts
            comic-mono
            crimson-pro
            fira-go
            fira-sans
            ibm-plex
            iosevka-comfy.comfy
            noto-fonts-emoji
            sf-mono-liga
          ];
      };
    });

    nixosConfigurations = {
      orpheus = nixpkgs.lib.nixosSystem {
        pkgs = legacyPackages.x86_64-linux;
        specialArgs = {inherit inputs;};
        modules =
          (builtins.attrValues nixosModules)
          ++ [
            ./host/orpheus/configuration.nix
          ];
      };
      sebastian = nixpkgs.lib.nixosSystem {
        pkgs = legacyPackages.aarch64-linux;
        specialArgs = {inherit inputs;};
        modules =
          (builtins.attrValues nixosModules)
          ++ [
            ./host/sebastian/configuration.nix
          ];
      };
    };
  };
}
