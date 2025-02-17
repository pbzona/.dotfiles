local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Appearance
config.color_scheme = 'darkmoss (base16)'

config.font = wezterm.font_with_fallback {
  'Berkeley Mono Variable',
  'Dank Mono', -- Bump up the font size if using this
  'GeistMono Nerd Font', 
  'Lilex Nerd Font'
}
config.font_size = 26

-- Window
config.window_frame = {
  font = wezterm.font { family = 'Berkeley Mono Variable' },
  font_size = 22,
}

config.window_background_opacity = 1.0
config.text_background_opacity = 0.8

-- Behavior
config.default_cwd = "$HOME"

return config
