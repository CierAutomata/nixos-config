{ config, pkgs, ... }:

let dot = "/home/briest/nixos-config/dotfiles"; in
{
  home.stateVersion = "26.05";
  home.username = "briest";
  home.homeDirectory = "/home/briest";

  xdg.configFile = {
    "alacritty".source  = config.lib.file.mkOutOfStoreSymlink (dot + "/alacritty/");
    "fastfetch".source  = config.lib.file.mkOutOfStoreSymlink (dot + "/fastfetch/");
    "fish".source       = config.lib.file.mkOutOfStoreSymlink (dot + "/fish/");
    "hypr".source       = config.lib.file.mkOutOfStoreSymlink (dot + "/hypr/");
    "kitty".source      = config.lib.file.mkOutOfStoreSymlink (dot + "/kitty/");
    "niri".source       = config.lib.file.mkOutOfStoreSymlink (dot + "/niri/");
    "noctalia".source   = config.lib.file.mkOutOfStoreSymlink (dot + "/noctalia/");
    "nvim".source       = config.lib.file.mkOutOfStoreSymlink (dot + "/nvim/");

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
