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

wezterm.on("update-right-status", function(window)
	window:set_right_status(wezterm.format({
		{ Attribute = { Italic = true } },
		{ Text = "@" .. window:active_workspace() .. " " },
	}))
end)

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

wezterm.on("user-var-changed", function(window, pane, name, value)
	if name == "SWITCH_WEZTERM_WORKSPACE" then
		window:perform_action(wezterm.action.SwitchToWorkspace({ name = value }), pane)
		wezterm.reload_configuration()
	end
end)

return config
