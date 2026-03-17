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
