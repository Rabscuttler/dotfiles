{ pkgs, packages, ... }:
{
  imports = [ ./shared.nix ];

  home.username = "laurence";
  home.homeDirectory = "/home/laurence";
  home.stateVersion = "24.11";

  home.packages = packages.corePackages;

  # Enable Nix PATH and environment for non-NixOS Linux
  targets.genericLinux.enable = true;

  # Ensure XDG base directories are set
  xdg.enable = true;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Suppress home-manager news
  news.display = "silent";

  # Git credential helper is auto-configured by programs.gh
}
