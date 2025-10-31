local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- General
config.default_prog = { os.getenv("HOME") .. "/.nix-profile/bin/nu", "--login" }
config.scrollback_lines = 100000
config.front_end = "WebGpu"

-- Window
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95
config.animation_fps = 120
config.max_fps = 120
config.cursor_blink_rate = 900
config.default_cursor_style = "BlinkingBar"

-- Font
config.font = wezterm.font_with_fallback({
	"Maple Mono",
	"Symbols Nerd Font",
})
config.font_size = 20
config.adjust_window_size_when_changing_font_size = false

require("keymaps").config(config)
require("colors").config(config)
require("tab_bar").config(config)

return config
