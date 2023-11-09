{
  description = "My personal nix configurations";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Darwin
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Nix user repository
    nur.url = "github:nix-community/NUR";

    # SFMono font with NerdFont and Ligatures
    sf-mono-liga = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  in rec {
    # Your custom packages and modifications
    overlays = {
      default = import ./overlay {inherit inputs;};
      nur = inputs.nur.overlay;
    };

    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;
    darwinModules = import ./modules/darwin;

    # Devshell for bootstrapping
    # Acessible through 'nix develop' or 'nix-shell' (legacy)
    devShells = forAllSystems (system: {
      default = legacyPackages.${system}.callPackage ./shell.nix {};
    });

    # This instantiates nixpkgs for each system listed above
    # Allowing you to add overlays and configure it (e.g. allowUnfree)
    # Our configurations will use these instances
    # Your flake will also let you access your package set through nix build, shell, run, etc.
    legacyPackages = forAllSystems (
      system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;

          # NOTE: Using `nixpkgs.config` in your NixOS config won't work
          # Instead, you should set nixpkgs configs here
          # (https://nixos.org/manual/nixpkgs/stable/#idm140737322551056)
          config.allowUnfree = true;
        }
    );

    nixosConfigurations = {
      orpheus = nixpkgs.lib.nixosSystem {
        pkgs = legacyPackages.x86_64-linux;
        specialArgs = {inherit inputs;}; # Pass flake inputs to our config
        modules =
          (builtins.attrValues nixosModules)
          ++ [
            ./host/orpheus/configuration.nix
          ];
      };
    };

    darwinConfigurations = {
      makoto = inputs.darwin.lib.darwinSystem {
        pkgs = legacyPackages.aarch64-darwin;
        specialArgs = {inherit inputs;}; # Pass flake inputs to our config
        modules =
          (builtins.attrValues darwinModules)
          ++ [
            ./host/makoto/configuration.nix
            # TODO: use home mangager as module
          ];
      };
    };

    homeConfigurations = let
      useFlakeNixpkgs = {
        nix.registry.nixpkgs.flake = nixpkgs; # Make CLI use the same nixpkgs commit as this config
      };
    in {
      "logan@makoto" = home-manager.lib.homeManagerConfiguration {
        pkgs = legacyPackages.aarch64-darwin;
        extraSpecialArgs = {inherit inputs;}; # Pass flake inputs to our config
        modules =
          (builtins.attrValues homeManagerModules)
          ++ [
            useFlakeNixpkgs
            ./home-manager/logan/makoto.nix
          ];
      };
      "logan@orpheus" = home-manager.lib.homeManagerConfiguration {
        pkgs = legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;}; # Pass flake inputs to our config
        modules =
          (builtins.attrValues homeManagerModules)
          ++ [
            useFlakeNixpkgs
            ./home-manager/logan/orpheus.nix
          ];
      };
    };
  };
}
