local wezterm = require("wezterm")
local mux = wezterm.mux
-- local act = wezterm.action
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#35333c"
-- custom.tab_bar.background = "#040404"
-- custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
-- custom.tab_bar.new_tab.bg_color = "#080808"


local config =
{
	-- default_prog = { '/usr/bin/env', 'fish' },
	-- Smart tab bar [distraction-free mode]
	hide_tab_bar_if_only_one_tab = true,
	enable_wayland = true,
	enable_scroll_bar = true,
	scrollback_lines = 5000,

	pane_focus_follows_mouse = true,
	warn_about_missing_glyphs = false,
	use_ime = true,
	xim_im_name = "fcitx5",
	front_end = "WebGpu",
	webgpu_power_preference = "HighPerformance",
	enable_kitty_graphics = true,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",

	-- Color scheme
	-- https://wezfurlong.org/wezterm/config/appearance.html
	--
	-- Dracula
	-- https://draculatheme.com
	window_padding = {
		left = 8,
	},

	color_schemes = {
		["kappuccin"] = custom,
	},
	color_scheme = "kappuccin",

	window_background_opacity = 0.95,



	-- Font configuration
	-- https://wezfurlong.org/wezterm/config/fonts.html
	font =
			wezterm.font_with_fallback {
				{ family = "Maple Mono" },
			},
	-- 	wezterm.font {
	-- 	family = "Maple Mono",
	-- 	weight = 'Light',
	-- 	harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }
	-- },

	font_size = 13.5,

	-- Cursor style
	default_cursor_style = "BlinkingBar",

	-- Enable CSI u mode
	-- https://wezfurlong.org/wezterm/config/lua/config/enable_csi_u_key_encoding.html
	enable_csi_u_key_encoding = true,

	keys = {

		{ key = ",", mods = "CTRL", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = ".", mods = "CTRL", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{
			key = 'w',
			mods = 'CTRL',
			action = wezterm.action.CloseCurrentPane { confirm = true },
		},
		{ key = 'n', mods = 'SHIFT|CTRL', action = wezterm.action.SpawnWindow },

	},

}
return config
