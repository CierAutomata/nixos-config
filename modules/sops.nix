{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/home/${config.myConfig.userName}/.config/sops/age/keys.txt";
      generateKey = false;
    };

    # Um das Passwort aus secrets.yaml zu nutzen, beides auskommentieren:
    # 1) Hier den richtigen YAML-Pfad angeben:
    # secrets.user-password = {
    #   key = "users/${config.myConfig.userName}/hashedPassword";
    #   neededForUsers = true;
    # };
    # 2) In hosts/<host>/configuration.nix ergänzen:
    # users.users.<name>.hashedPasswordFile = config.sops.secrets.user-password.path;
  };
}
