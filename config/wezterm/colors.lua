local wezterm = require("wezterm")
local M = {}

function M.get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function M.scheme_for_appearance(appearance)
	if appearance:find("Light") then
		return "Catppuccin Latte"
	else
		return "Catppuccin Mocha"
	end
end

--- Returns the actual window background color (including opacity)
function M.window_bg_color(config, color_scheme)
	local bg = color_scheme.background
	if type(bg) == "string" then
		bg = wezterm.color.parse(bg)
	end
	local r, g, b, _ = bg:srgba_u8()
	return string.format("rgba(%s, %s, %s, %s)", r, g, b, config.window_background_opacity or 1)
end

function M.config(config)
	config.color_scheme = M.scheme_for_appearance(M.get_appearance())
	local builtin_color_schemes = wezterm.get_builtin_color_schemes()
	config.color_schemes = {
		["Catppuccin Latte"] = builtin_color_schemes["Catppuccin Latte"],
		["Catppuccin Mocha"] = builtin_color_schemes["Catppuccin Mocha"],
	}
	config.color_schemes["Catppuccin Latte"].background =
		wezterm.color.parse(config.color_schemes["Catppuccin Latte"].background):darken(0.03)
	return config
end

return M
