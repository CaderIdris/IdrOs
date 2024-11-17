local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local distrobox = wezterm.plugin.require("https://github.com/CaderIdris/distrobox.wezterm")

config.window_close_confirmation = 'NeverPrompt'

config.color_scheme = 'GruvboxDark'

config.window_padding = {
        left = 2,
        right = 2,
        top = 0,
        bottom = 0
}

config.window_decorations = 'RESIZE'

config.window_background_opacity = 1

config.adjust_window_size_when_changing_font_size = false
config.use_fancy_tab_bar = false

config.unicode_version = 14

wezterm.on('toggle-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 0.5
  else
    overrides.window_background_opacity = nil
  end
  window:set_config_overrides(overrides)
end)

config.keys = {
    {
      key = 'B',
      mods = 'CTRL|ALT',
      action = wezterm.action.EmitEvent 'toggle-opacity',
    },
}
-- Taken from https://www.lua.org/pil/13.4.3.html
function set_default(t, d)
	local mt = {__index = function () return d end}
	setmetatable(t, mt)
end

local distrobox_enter_commands = {
	["datblygiad"]="tmux",
	["datblygiad-nvidia"]="tmux"
}

set_default(distrobox_enter_commands, "tmux")

distrobox.apply_to_config(config, {entry_commands=distrobox_enter_commands})
return config
