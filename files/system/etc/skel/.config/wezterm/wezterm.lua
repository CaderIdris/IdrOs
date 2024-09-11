local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

local function get_distrobox_containers ()
	local flatpak_command = "flatpak-spawn --host distrobox list --no-color | awk -v col=3 '{print $col}' - | tail -n +2"
	local wt_is_flatpak = os.execute(flatpak_command)
	local on_host_command = "distrobox list --no-color | awk -v col=3 '{print $col}' - | tail -n +2"
	local wt_is_host = os.execute(on_host)
	local cmd = ""
	if wt_is_flatpak then
		cmd = flatpak_command
	elseif wt_is_host then
		cmd = on_host_command
	else
		wezterm.log_info("Distrobox not found")
		return {}
	end
	local handle = io.popen(cmd)
	local output = handle:read('*a')
	local dbox_options = {}
	for s in output:gmatch("[^\r\n]+") do
		wezterm.log_info(s)
		table.insert(
			dbox_options,
			{
				label = tostring(s),
				id = "distrobox - " .. tostring(s)
			}
		)
	end
	return dbox_options

end

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
	{
    		key = 'R',
		mods = 'CTRL|SHIFT',
		action = wezterm.action_callback(function(window, pane)


			local choices = {
				{
					id = "",
					label = wezterm.format {
						{ Foreground = { AnsiColor = 'Teal' } },
						{ Text = 'Host Shell' }
					},
				}
			}
			for _, v in ipairs(get_distrobox_containers()) do
				table.insert(choices, v)
			end

			window:perform_action(
				act.InputSelector {
					action = wezterm.action_callback(
						function(window, pane, id, label)
							if not id and not label then
								wezterm.log_info 'cancelled'
							else
								local cmd = {}
								if string.find(id, "distrobox - ") then
									cmd = {'distrobox', 'enter', '--name', tostring(label), '--no-workdir', '--', 'tmux'}
								end
								local mux_win = window:mux_window()
								if id ~= "" then
									local tab = mux_win:spawn_tab(
										{
											args = cmd,
										}
									)
									wezterm.log_info('you selected ', label)
								else
									local tab = mux_win:spawn_tab(
										{
										}
									)
									wezterm.log_info('you selected host shell')
								end
							end
						end
						),
						title = 'Containers',
						choices = choices,
						description = 'Choose your container',
					},
				pane
			)
			end
		),
	},
}

return config
