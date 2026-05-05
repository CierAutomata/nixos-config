{ config, pkgs, ... }:

let
  user = builtins.getEnv "USER";
  dot  = "/home/${user}/nixos-config/dotfiles";
in
{
  home.stateVersion = "26.05";
  home.username = user;
  home.homeDirectory = "/home/${user}";

  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink (dot + "/hypr/");
    "niri".source = config.lib.file.mkOutOfStoreSymlink (dot + "/niri/");
    "nvim".source = config.lib.file.mkOutOfStoreSymlink (dot + "/nvim/");
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink (dot + "/alacritty/");
    "noctalia".source = config.lib.file.mkOutOfStoreSymlink (dot + "/noctalia/");
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink (dot + "/fastfetch/");
    "fish".source = config.lib.file.mkOutOfStoreSymlink (dot + "/fish/");
    "kitty".source = config.lib.file.mkOutOfStoreSymlink (dot + "/kitty/");
    "fuzzel".source = config.lib.file.mkOutOfStoreSymlink (dot + "/fuzzel/");
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink (dot + "/starship.toml");

    "hypr-host.conf".text = ''source = ${dot}/hypr/hosts/fedora.conf'';
    "niri-host.kdl".text  = ''include "${dot}/niri/hosts/fedora.kdl"'';
  };

  home.packages = with pkgs; [
    yazi
  ];

  xdg.desktopEntries.kitty-yazi = {
    name = "Yazi (Kitty)";
    exec = "kitty -- yazi %f";
    icon = "yazi";
    type = "Application";
    mimeType = [ "inode/directory" "inode/mount-point" "x-scheme-handler/file" ];
    categories = [ "FileManager" "System" ];
    noDisplay = true;
  };

  home.file.".bashrc".source =
    config.lib.file.mkOutOfStoreSymlink (dot + "/.bashrc");

  programs.git = {
    enable = true;
    settings.user.name = "CierAutomata";
    settings.user.email = "CierAutomata@pm.me";
  };
}
