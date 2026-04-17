{ config, pkgs, lib, ... }:

lib.mkIf config.myConfig.isLaptop {
  # Akku-Optimierung
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Bildschirmhelligkeit ohne sudo
  environment.systemPackages = [ pkgs.brightnessctl ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';
  users.users.${config.myConfig.userName}.extraGroups = [ "video" ];

  # Lid-Switch Verhalten
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "lock";
  };

  # Akku-Status im System
  services.upower.enable = lib.mkForce true;
}
