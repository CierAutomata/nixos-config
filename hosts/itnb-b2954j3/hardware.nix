{ config, lib, pkgs, modulesPath, ...  }:
{
  # Beispiel: persistenter Daten-Mount der nach Neuinstallation erhalten bleibt
  # fileSystems."/data" = {
  #   device = "/dev/disk/by-label/itnb-b2954j3-data";
  #   fsType = "ext4";
  #   options = [ "defaults" "nofail" ];
  # };
}
