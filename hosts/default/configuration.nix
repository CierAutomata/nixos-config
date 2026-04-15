{ config, pkgs, ... }:

{
  imports = [
    ./hardware-gen.nix
    ../../modules/core.nix
    ../../modules/desktop.nix
  ];
  networking.hostName = "flocke";


  users.users.cier = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "video" ];
    #hashedPasswordFile = config.sops.secrets.user-password.path;
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml; # Pfad zu deiner verschlüsselten Datei
    defaultSopsFormat = "yaml";

    age = {
      # Dies nutzt den SSH-Key des Hosts als Entschlüsselungs-Key
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # Wo die age-keys (vom YubiKey/Backup) liegen sollen
      keyFile = "/var/lib/sops-nix/key.txt"; 
      generateKey = true;
    };
    secrets.user-password = {
      #neededForUsers = true; # Wichtig, wenn es für den Login-User ist
    };
  };
  
  services.openssh = {
  enable = true;
  settings.PasswordAuthentication = false; # Sicherheit geht vor!
  # Dies stellt sicher, dass Ed25519 Keys generiert werden (sicherer & kürzer)
  hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
};
  
  console.keyMap = "en";
  services.xserver.xkb = {
    layout = "en";
    variant = "";
  };
  environment.systemPackages = with pkgs; [
    sops
    age
    age-plugin-yubikey
  ];
  # Wichtig für Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  system.stateVersion = "24.05";
}
