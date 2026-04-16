{ pkgs, ... }:

{
  # Universal Wayland Session Manager
  programs.uwsm.enable = true;

  # General system packages for desktop use
  environment.systemPackages = with pkgs; [
    noctalia-shell
    discord
    alacritty
    greetd.tuigreet
    firefox
    brave
    code
    yazi
  ];

  # Bluetooth and power management
  hardware.bluetooth.enable = true;
  services.upower.enable = true;
}

