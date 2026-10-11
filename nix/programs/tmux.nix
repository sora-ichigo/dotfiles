{ pkgs, ... }:

let
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

  sessionsScript = pkgs.writeShellScript "tmux-sessions" ''
    tmux list-sessions -F '#S' | LC_ALL=C sort | awk -v cur="$1" -v fg="$2" -v bg="$3" -v cfg="$4" -v cbg="$5" '{
      if ($0 == cur) printf "#[fg=%s,bg=%s,bold] %d %s #[default] ", cfg, cbg, NR, $0
      else printf "#[fg=%s,bg=%s] %d %s #[default] ", fg, bg, NR, $0
    }'
  '';

  switchSessionScript = pkgs.writeShellScript "tmux-switch-session" ''
    name=$(tmux list-sessions -F '#S' | LC_ALL=C sort | sed -n "$1p")
    [ -n "$name" ] && tmux switch-client -t "=$name"
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
          set -g @catppuccin_flavor "mocha"
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

      set -g automatic-rename-format "#{?#{m/r:^[0-9]+[.][0-9]+[.][0-9]+$,#{pane_current_command}},claude,#{pane_current_command}}"

      set -g status-left "#(${sessionsScript} '#{client_session}' '#{@thm_subtext_0}' '#{@thm_surface_0}' '#{@thm_crust}' '#{@thm_green}')#[fg=#{@thm_overlay_0}]│ "

      set -g status-right "#[fg=#{@thm_mauve}] #(${gitStatusScript} '#{pane_current_path}')  "
      set -ag status-right "#[fg=#{@thm_yellow}] #{cpu_percentage}  "
      set -ag status-right "#[fg=#{@thm_lavender}]#{battery_icon_status} #{battery_percentage}  "
      set -ag status-right "#[fg=#{@thm_overlay_1}]%H:%M "

      run-shell ${pkgs.tmuxPlugins.cpu.rtp}
      run-shell ${pkgs.tmuxPlugins.battery.rtp}

      bind v split-window -h -c "#{pane_current_path}"
      bind "|" split-window -h -c "#{pane_current_path}"
      bind "-" split-window -v -c "#{pane_current_path}"

      unbind s
      bind s switch-client -T session
      bind -T session 1 run-shell "${switchSessionScript} 1"
      bind -T session 2 run-shell "${switchSessionScript} 2"
      bind -T session 3 run-shell "${switchSessionScript} 3"
      bind -T session 4 run-shell "${switchSessionScript} 4"
      bind -T session 5 run-shell "${switchSessionScript} 5"
      bind -T session 6 run-shell "${switchSessionScript} 6"
      bind -T session 7 run-shell "${switchSessionScript} 7"
      bind -T session 8 run-shell "${switchSessionScript} 8"
      bind -T session 9 run-shell "${switchSessionScript} 9"
      bind S choose-tree -Zs

      bind T run-shell "sesh connect \"\$({ sesh list -i; ghq list -p | grep -v -- '-worktrees/' | sed \"s|^\$HOME|~|\"; } | awk '!seen[\$NF]++' | fzf-tmux -p 60%,60% --ansi --no-sort --reverse --border-label ' sesh ' --color=bg:-1,bg+:-1,gutter:-1,hl:#cba6f7,hl+:#cba6f7:bold,fg:#cdd6f4,fg+:#cdd6f4:bold,prompt:#89b4fa,pointer:#f38ba8,marker:#a6e3a1,border:#89b4fa,label:#89b4fa)\""

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
