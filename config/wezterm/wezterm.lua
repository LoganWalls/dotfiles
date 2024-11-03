local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

-- General
config.default_prog = { "/Users/logan/.nix-profile/bin/nu", "--login" }
config.scrollback_lines = 1000000
config.front_end = "WebGpu" -- See https://github.com/wez/wezterm/issues/5990

-- Keybinds
config.keys = {
	-- Change tabs easily
	{
		key = "[",
		mods = "ALT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "]",
		mods = "ALT",
		action = wezterm.action.ActivateTabRelative(1),
	},
	-- Navigate text quickly with alt and cmd
	{
		key = "LeftArrow",
		mods = "ALT",
		action = act.SendKey({
			key = "b",
			mods = "ALT",
		}),
	},
	{
		key = "RightArrow",
		mods = "ALT",
		action = act.SendKey({
			key = "f",
			mods = "ALT",
		}),
	},
	{
		key = "LeftArrow",
		mods = "SUPER",
		action = act.SendKey({
			key = "a",
			mods = "CTRL",
		}),
	},
	{
		key = "RightArrow",
		mods = "SUPER",
		action = act.SendKey({
			key = "e",
			mods = "CTRL",
		}),
	},
}

-- Window
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.90
config.macos_window_background_blur = 20
config.animation_fps = 60
config.cursor_blink_rate = 900
config.default_cursor_style = "BlinkingBar"

-- Font
config.font = wezterm.font_with_fallback({
	"Liga SFMono Nerd Font",
	"Symbols Nerd Font",
})
config.font_size = 20
config.adjust_window_size_when_changing_font_size = false

-- Colors
local color_scheme_name = "Catppuccin Mocha"
local color_scheme = wezterm.get_builtin_color_schemes()[color_scheme_name]
color_scheme.background = "#1e1e2e"
config.color_schemes = { [color_scheme_name] = color_scheme }
config.color_scheme = color_scheme_name

-- Tab bar
-- config.enable_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.show_tab_index_in_tab_bar = false
config.use_fancy_tab_bar = false
local tab_bar_background = "rgba(0,0,0,0)"
local tab_active_fg = color_scheme.ansi[4]
local tab_inactive_fg = color_scheme.ansi[1]
config.window_frame = {
	active_titlebar_bg = tab_bar_background,
	inactive_titlebar_bg = tab_bar_background,
}
config.colors = {
	tab_bar = {
		background = tab_bar_background,
		inactive_tab_edge = tab_bar_background,
		active_tab = {
			bg_color = tab_bar_background,
			fg_color = tab_active_fg,
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = tab_bar_background,
			fg_color = tab_inactive_fg,
			intensity = "Half",
		},
	},
}
-- Add padding around the tab titles
local function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end
	return tab_info.active_pane.title
end
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)
	return { { Text = "  " .. title .. "  " } }
end)

-- Enable zen-mode to change the font size
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

return config
