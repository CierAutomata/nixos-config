{ inputs, lib, ... }:

{
  flake.homeConfigurations =
    lib.genAttrs
      (builtins.attrNames (builtins.readDir ../standalone))
      (hostname: inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ../standalone/${hostname}/configuration.nix ];
      });
}
