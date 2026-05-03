{ config, lib, inputs, ... }:

# Bindet home.nix dynamisch für den in myConfig.userName konfigurierten User ein.
# Hosts müssen home-manager nicht selbst konfigurieren.
{
  home-manager.useGlobalPkgs = lib.mkDefault true;
  home-manager.useUserPackages = lib.mkDefault true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.${config.myConfig.userName} = import ./home.nix;
}
