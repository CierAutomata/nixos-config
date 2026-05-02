{ config, lib, pkgs, modulesPath, ...  }:
{
  
  # Beispiel: persistenter Daten-Mount der nach Neuinstallation erhalten bleibt
  fileSystems."/home/cier/games" = {
    device = "/dev/disk/by-uuid/6985268c-81e1-4289-baf7-7e8794b63077";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };
  boot.kernelPackages = pkgs.linuxPackages_zen;

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = true;
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable32Bit = true;
  hardware.bluetooth.enable = true;
}
