{ config, pkgs, ... }:

{
  imports = [
    ./hardware-gen.nix
    ../../modules/boot.nix
    ../../modules/nix-setup.nix
    ../../modules/core.nix
    ../../modules/tools.nix
    ../../modules/desktop.nix
    ../../modules/wm-hyprland.nix
    # ../../modules/wm-sway.nix       # Uncomment to use Sway instead
    # ../../modules/wm-i3.nix         # Uncomment to use i3 instead
    ../../modules/sops.nix
  ];

  networking.hostName = "flocke";

  users.users.cier = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "video" "disk" "storage" ];
    #hashedPasswordFile = config.sops.secrets.user-password.path;
  };

  users.mutableUsers = true;

  system.stateVersion = "26.05";
}
