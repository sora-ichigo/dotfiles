{ pkgs, ... }:

let
  ssidScript = pkgs.writeShellScript "tmux-ssid" ''
    ssid=$(ipconfig getsummary en0 2>/dev/null \
      | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')
    [ -z "$ssid" ] && ssid="--"
    printf '%s' "$ssid" | head -c 18
  '';

  gitStatusScript = pkgs.writeShellScript "tmux-git-status" ''
    cd "$1" 2>/dev/null || { printf '%s' "--"; exit; }
    branch=$(git symbolic-ref --short HEAD 2>/dev/null \
      || git rev-parse --short HEAD 2>/dev/null)
    if [ -z "$branch" ]; then
      printf '%s' "--"
      exit
    fi
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      printf '%s*' "$branch"
    else
      printf '%s' "$branch"
    fi
  '';
in
{
  programs.tmux = {
    enable = true;
    prefix = "C-t";
    keyMode = "vi";
    mouse = true;
    terminal = "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "latte"
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_default_text " #W"
          set -g @catppuccin_window_current_text " #W"
          set -g @catppuccin_status_background "default"
          set -g @catppuccin_status_left_separator  "█"
          set -g @catppuccin_status_right_separator "█"
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim "session"
          set -g @resurrect-capture-pane-contents "on"
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore "on"
          set -g @continuum-save-interval "15"
        '';
      }
    ];

    extraConfig = ''
      set -ag terminal-overrides ",xterm-256color:RGB"

      set -g status-position "top"
      set -g status-justify "left"
      set -g status-interval 2

      set -g pane-active-border-style fg=colour66
      set -g status-style "bg=default,fg=default"
      set -g window-status-style "bg=default"
      set -g window-status-current-style "bg=default"
      set -g popup-style "bg=default"
      set -g popup-border-style "fg=#{@thm_blue}"

      set -g status-left-length 120
      set -g status-right-length 200

      set -g @online_icon "▲ UP"
      set -g @offline_icon "▽ DN"

      set -g status-left "#[fg=#{@thm_crust},bg=#{@thm_green}] ◉ #S #[fg=#{@thm_green},bg=default]█ "

      set -g status-right "#[fg=#{@thm_sky},bg=default]█#[fg=#{@thm_crust},bg=#{@thm_sky}] SSID #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #(${ssidScript}) "
      set -ag status-right "#[fg=#{@thm_green},bg=default]█#[fg=#{@thm_crust},bg=#{@thm_green}] LINK #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{online_status} "
      set -ag status-right "#[fg=#{@thm_yellow},bg=default]█#[fg=#{@thm_crust},bg=#{@thm_yellow}] CPU #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{cpu_percentage} "
      set -ag status-right "#[fg=#{@thm_lavender},bg=default]█#[fg=#{@thm_crust},bg=#{@thm_lavender}] PWR #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{battery_icon_status} #{battery_percentage} "
      set -ag status-right "#[fg=#{@thm_mauve},bg=default]█#[fg=#{@thm_crust},bg=#{@thm_mauve}] GIT #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #(${gitStatusScript} '#{pane_current_path}') "
      set -ag status-right "#[fg=#{@thm_overlay_0},bg=default]█#[fg=#{@thm_fg},bg=#{@thm_overlay_0}] %m/%d (%a) %H:%M "

      run-shell ${pkgs.tmuxPlugins.cpu.rtp}
      run-shell ${pkgs.tmuxPlugins.battery.rtp}
      run-shell ${pkgs.tmuxPlugins.online-status.rtp}

      bind v split-window -h -c "#{pane_current_path}"
      bind "|" split-window -h -c "#{pane_current_path}"
      bind "-" split-window -v -c "#{pane_current_path}"

      unbind s
      bind S choose-tree -Zs

      bind T run-shell "sesh connect \"\$({ sesh list -i; ghq list -p | grep -v -- '-worktrees/' | sed \"s|^\$HOME|~|\"; } | awk '!seen[\$NF]++' | fzf-tmux -p 60%,60% --ansi --no-sort --reverse --border-label ' sesh ' --color=bg:-1,bg+:-1,gutter:-1,hl:#8839ef,hl+:#8839ef:bold,fg:#4c4f69,fg+:#4c4f69:bold,prompt:#1e66f5,pointer:#d20f39,marker:#40a02b,border:#1e66f5,label:#1e66f5)\""

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi V send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi Y send -X copy-line
      bind -T copy-mode-vi Enter send -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "pbcopy"
      bind-key C-p paste-buffer
    '';
  };

  home.packages = [ pkgs.sesh ];
}
