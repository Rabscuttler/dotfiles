{ pkgs, lib, ... }:
{
  # Disable manual generation (speeds up builds)
  manual = {
    html.enable = false;
    manpages.enable = false;
    json.enable = false;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing = {
      key = null; # use default GPG key
      signByDefault = true;
    };
    settings = {
      user.name = "Laurence Watson";
      user.email = "laurence@furbnow.com";
      core.editor = "vim";
      pull.rebase = true;
      push.autoSetupRemote = true;
      alias.sync = "!git fetch origin $1 && git reset --hard origin/$1";
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
      pain-control
    ];
    extraConfig = ''
      set -g @yank_action 'copy-pipe-no-clear'

      bind -T copy-mode    C-c send -X copy-pipe-no-clear "xsel -i --clipboard"
      bind -T copy-mode-vi C-c send -X copy-pipe-no-clear "xsel -i --clipboard"

      bind -T copy-mode    DoubleClick1Pane select-pane \; send -X select-word \; send -X copy-pipe-no-clear "xsel -i"
      bind -T copy-mode-vi DoubleClick1Pane select-pane \; send -X select-word \; send -X copy-pipe-no-clear "xsel -i"
      bind -n DoubleClick1Pane select-pane \; copy-mode -M \; send -X select-word \; send -X copy-pipe-no-clear "xsel -i"
      bind -T copy-mode    TripleClick1Pane select-pane \; send -X select-line \; send -X copy-pipe-no-clear "xsel -i"
      bind -T copy-mode-vi TripleClick1Pane select-pane \; send -X select-line \; send -X copy-pipe-no-clear "xsel -i"
      bind -n TripleClick1Pane select-pane \; copy-mode -M \; send -X select-line \; send -X copy-pipe-no-clear "xsel -i"
    '';
  };

  programs.neovim.enable = true;

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      filter_mode = "directory";
      enter_accept = true;
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
