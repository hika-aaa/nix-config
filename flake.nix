{
  description = "NixOS configuration";

    # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # override the default substituters
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://umbriel.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
    ];
    trusted-users = ["root" "@wheel"];
  };


  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    grimoire.url = "github:Slush97/grimoire";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    umbriel = {
      url = "github:noctalia-dev/umbriel";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, stylix, nix-index-database, ... }:
  let
      # Helper for automatic host discovery
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}
          ./shared-config.nix
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          nix-index-database.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            #home-manager.users.hika = ./home.nix;
            home-manager.users.hika = ./hosts/${hostname}/home.nix;
            #home-manager.users.hika = import [ ./shared-home.nix  ./hosts/${hostname}/home.nix ];
            programs.nix-index-database.comma.enable = true;
          }
#           home-manager.nixosModules.home-manager
#           {
#             networking.hostName = hostname;
#             home-manager = {
#               useGlobalPkgs = true;
#               useUserPackages = true;
#               users.fuhrmann = import ./modules/user;
#               extraSpecialArgs = { inherit inputs; };
#               sharedModules = [
#                 inputs.niri.homeModules.niri
#                 inputs.vicinae.homeManagerModules.default
#                 inputs.noctalia.homeModules.default
#                 inputs.nix-colors.homeManagerModules.default
#               ];
#             };
#          }
        ];
      };
    in {
    nixosConfigurations =
      {
      nixos = mkHost "nixos";
      nixos-laptop = mkHost "nixos-laptop";
      };
#     nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
#       system = "x86_64-linux";
#       #specialArgs.inputs = inputs;
#       specialArgs = {inherit inputs;};
#       modules = [
#         ./configuration.nix
#         stylix.nixosModules.stylix
#         home-manager.nixosModules.home-manager
#         {
#           home-manager.useGlobalPkgs = true;
#           home-manager.useUserPackages = true;
#           home-manager.extraSpecialArgs = { inherit inputs; };
#           home-manager.users.hika = ./home.nix;
#         }
#       ];
#     };
    };
}
