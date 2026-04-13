{ self, inputs, ... }: {
  flake.nixosConfigurations.flocke = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.flockeConfiguration
    ];
  };
}