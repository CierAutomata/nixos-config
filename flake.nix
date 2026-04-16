{
  description = "NixOS Flake - Niri, Noctalia & Neovim IDE";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs: let
    hosts = builtins.attrNames (builtins.readDir ./hosts);
    hostConfigs = builtins.listToAttrs (map (host: {
      name = host;
      value = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${host}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.cier = import ./modules/home.nix;
          }
          sops-nix.nixosModules.sops
        ];
      };
    }) hosts);
  in {
    nixosConfigurations = hostConfigs;
  };
}
