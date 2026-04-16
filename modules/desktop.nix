{ pkgs, ... }:

{
  programs.uwsm.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "cier";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    noctalia-shell
    discord
    alacritty
    greetd.tuigreet
    waybar
    hyprpaper
    hyprlock
    firefox
    rofi
    brave
    code
    yazi
  ];

  hardware.bluetooth.enable = true;
  services.upower.enable = true;

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
