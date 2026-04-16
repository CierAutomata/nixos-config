{ pkgs, ... }:

{
  # Niri window manager configuration
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Login manager configured for Niri
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start niri'";
        user = "cier";
      };
    };
  };

  # Niri-specific packages
  environment.systemPackages = with pkgs; [
    waybar
    swaylock
    swayidle
    rofi-wayland
    alacritty
  ];

  # XDG portal configuration for Niri
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [ "gtk" ];
      niri.default = [ "wlr" ];
      noctalia.default = [ "wlr" ];
    };
  };
}
