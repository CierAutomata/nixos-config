{ pkgs, ... }:

{
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  programs.git.enable = true;

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

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}