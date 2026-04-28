{ config, pkgs, lib,  ... }:

{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
    ./hardware.nix 
    ];

  nixpkgs.hostPlatform = "x86_64-linux";

  myConfig = {
    wm = "hyprland";
    isLaptop = true;
    userName = "briest";
    sddmTheme = "default";
    keyboard = "us";
    # configDir = "/home/briest/nixos-config"; # Standard, nur ändern wenn Repo woanders liegt
  };

  networking.hostName = "itnb-b2954j3";

  virtualisation.docker.enable = true;

  users.users.briest = {
    isNormalUser = true;
    description = "briest";
    extraGroups = [ "wheel" "networkmanager" "disk" "storage" "docker" ];
    #hashedPasswordFile = config.sops.secrets.user-password.path;
  };

  #users.users.root = {
  #  hashedPasswordFile = config.sops.secrets.root-password.path;
  #};

  #users.mutableUsers = false;
  system.stateVersion = "26.05";
  hardware.bluetooth.enable = true;

}
