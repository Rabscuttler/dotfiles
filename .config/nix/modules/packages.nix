{ pkgs }:
let
  # Core — installed on all machines (Mac + NUC)
  corePackages = with pkgs; [
    # Shell & terminal
    zsh
    tmux

    # neovim — provided by programs.neovim.enable in shared.nix

    # Navigation & search
    fd
    ripgrep
    ripgrep-all
    fzf
    tree
    eza

    # Git
    gh
    lazygit
    git-quick-stats

    # Data
    jq
    bat

    # Shell tools
    atuin
    direnv
    starship

    # Misc
    hyperfine
    pandoc
  ];

  # Workstation extras — Mac only
  workstationExtras = with pkgs; [
    imagemagick
    lazysql
    libpq
    cmake
    watchman
    pinentry_mac
    # peon-ping — installed via brew tap (peonping/tap/peon-ping), not in nixpkgs
  ];
in
{
  inherit corePackages;
  workstationPackages = corePackages ++ workstationExtras;
}
