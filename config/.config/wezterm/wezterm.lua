local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Regular" })
config.font_size = 14

-- config.color_scheme = 'Tokyo Night'

config.window_background_opacity = 1
-- config.macos_window_background_blur = 20

-- config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.use_ime = true

config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "RESIZE"

config.leader = { key = "a", mods = "CMD" }
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables

return config
