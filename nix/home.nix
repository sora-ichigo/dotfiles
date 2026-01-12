{ config, pkgs, ... }:

{
  home.username = "ichigo";
  home.homeDirectory = "/Users/ichigo";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    wget
    curl
    htop
    gnumake
    gcc
    direnv
    fzf
    gnused
    bat
    lazygit
    coreutils
    libffi
    nnn
    awscli2
    luarocks
    libpq
    postgresql
    starship
    tmux
    ghq
  ];

  programs.git = {
    enable = true;
    userName = "Sora ichigo";
    userEmail = "igsr5.dev@gmail.com";

    aliases = {
      a = "add -p";
      an = "add -N";
      c = "commit";
      ci = "commit --allow-empty -m 'initial commit'";
      p = "push";
      ph = "push origin HEAD";
      m = "merge";
      mm = "!git merge $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')";
      f = "fetch origin";
      s = "status";
      d = "diff";
      l = "log";
      co = "checkout";
      cb = "checkout -b";
      cm = "!git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')";
      pl = "!git pull origin $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')";
      w = "worktree";
    };

    ignores = [
      ".serena"
      ".mcp.json"
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"
      ".claude/settings.local.json"
      ".worktree"
      ".envrc"
    ];

    extraConfig = {
      core = {
        editor = "nvim";
        filemode = true;
        hooksPath = "~/.git_template/hooks";
      };
      color.ui = true;
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      pull = {
        rebase = true;
        default = "current";
      };
      branch.autoSetupRebase = "always";
      submodule.recurse = true;
      init.defaultBranch = "master";
      url = {
        "git@github.com:" = {
          pushInsteadOf = [
            "https://github.com/"
            "git://github.com/"
          ];
          insteadOf = "https://github.com/";
        };
        "git@gist.github.com:" = {
          pushInsteadOf = [
            "https://gist.github.com/"
            "git://gist.github.com/"
          ];
        };
      };
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      version = "1";
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        r = "repo view --web";
        v = "pr view --web";
        c = "pr create --fill --draft --assignee @me";
      };
    };
  };

  home.file.".git_template/hooks/pre-commit" = {
    executable = true;
    text = ''
      #!/bin/bash

      # DO NOT EDIT frolint START

      scriptPath="node_modules/frolint/index.js"
      hookName="pre-commit"
      gitParams="$*"

      if ! command -v node >/dev/null 2>&1; then
        echo "Can't find node in PATH, trying to find a node binary on your system"
      fi
      if [ -f $scriptPath ]; then
        node $scriptPath $hookName "$gitParams"
      fi

      # DO NOT EDIT frolint END
    '';
  };

  home.file.".git_template/hooks/pre-push" = {
    executable = true;
    text = ''
      #!/bin/bash
      # pre-push hook (currently disabled)
    '';
  };
}
