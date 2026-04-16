{ pkgs, ... }:

{
  # Hyprland window manager configurations
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # Login manager configured for Hyprland
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "cier";
      };
    };
  };

  # Hyprland-specific packages
  environment.systemPackages = with pkgs; [
    waybar
    hyprpaper
    hyprlock
    rofi
  ];

  # XDG portal configuration for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [ "hyprland" ];
      noctalia.default = [ "wlr" ];
    };
  };
}
