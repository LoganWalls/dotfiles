{
  description = "My personal nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    flakey-profile.url = "github:lf-/flakey-profile";
    llm-agents.url = "github:numtide/llm-agents.nix";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    kanata-tray.url = "github:rszyma/kanata-tray";
    kanata-tray.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    sf-mono-liga = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakey-profile,
    nix-darwin,
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
      llm-agents = inputs.llm-agents.overlays.default;
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

    packages = forAllSystems (system: let
      pkgs = legacyPackages."${system}";
    in {
      profile.logan =
        pkgs.callPackage ./profiles/logan.nix {inherit pkgs inputs;};
    });

    darwinConfigurations.makoto = nix-darwin.lib.darwinSystem {
      pkgs = legacyPackages.aarch64-darwin;
      specialArgs = {inherit self inputs;};
      modules = [./host/makoto/configuration.nix];
    };

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
