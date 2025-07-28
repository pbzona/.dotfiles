local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Appearance
-- config.color_scheme = "darkmoss (base16)"
config.color_scheme = "Bamboo Multiplex"

config.font = wezterm.font_with_fallback({
	"Input",
	"Berkeley Mono",
	"Dank Mono", -- Bump up the font size if using this
	"MartianMono Nerd Font",
	"GeistMono Nerd Font",
	"Lilex Nerd Font",
})
config.font_size = 26

-- Window
config.window_frame = {
	font = wezterm.font({ family = "Berkeley Mono Variable" }),
	font_size = 20,
}

config.window_background_opacity = 1.0
config.text_background_opacity = 1.0

-- Commands
config.command_palette_font_size = 24
config.command_palette_fg_color = "#48a8cc"
config.command_palette_bg_color = "#223344"

-- Behavior
config.default_cwd = "$HOME"

-- Keybindings
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
	{
		key = "|",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
}

return config
