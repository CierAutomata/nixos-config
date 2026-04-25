{ pkgs, ... }:

{
  networking.networkmanager.enable = true;

#  services.openssh = {
#    enable = true;
#    settings = {
#      PasswordAuthentication = false;
#      PermitRootLogin = "no";
#    };
#    hostKeys = [
#      { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
#    ];
#  };

  services.pcscd.enable = true;
  i18n.defaultLocale = "de_DE.UTF-8";

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    TERMINAL = "alacritty";
    XDG_TERMINA_EXEC = "alacritty";
  };
}