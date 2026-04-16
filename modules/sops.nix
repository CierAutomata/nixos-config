{ config, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/home/cier/.config/sops/age/keys.txt";
      generateKey = true;
    };

    secrets.user-password = {
      neededForUsers = true;
    };
  };
}
