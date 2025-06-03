local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font('JetBrains Mono', { weight = 'Regular' })
config.font_size = 14

-- config.color_scheme = 'Tokyo Night'

config.window_background_opacity = 1
-- config.macos_window_background_blur = 20

-- config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.use_ime = true

config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "RESIZE"

config.leader = { key = "t", mods = "CTRL" }
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables

 wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
   local background = "#000000"
   local foreground = "#FFFFFF"

   if tab.is_active then
     background = "#5bcdcb"
     foreground = "#FFFFFF"
   end

   local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

   return {
     { Background = { Color = background } },
     { Foreground = { Color = foreground } },
     { Text = title },
   }
 end)


return config
