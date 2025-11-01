local wezterm = require("wezterm")
local M = {}

function M.config(config)
	local color_scheme = config.color_schemes[config.color_scheme]
	local tab_bar_background = require("colors").window_bg_color(config, color_scheme)
	local tab_active_fg = color_scheme.foreground
	local tab_inactive_fg = color_scheme.ansi[1]

	config.show_new_tab_button_in_tab_bar = false
	config.show_tab_index_in_tab_bar = false
	config.use_fancy_tab_bar = false
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
	local function tab_title(tab_info)
		local title = tab_info.tab_title
		if title and #title > 0 then
			return title
		end
		local proc = tab_info.active_pane.foreground_process_name
		local path = proc:match("^[^ ]*") or ""
		local basename = path:match("([^/]+)$")
		local aliases = {
			[".nu-wrapped"] = "nu",
		}
		for key, value in pairs(aliases) do
			if basename == key then
				basename = value
			end
		end
		return basename
	end
	wezterm.on("format-tab-title", function(tab)
		local title = tab_title(tab)
		return { { Text = "  " .. title .. "  " } }
	end)

	return config
end

return M
