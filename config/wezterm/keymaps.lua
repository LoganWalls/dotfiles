local act = require("wezterm").action

local M = {}
function M.config(config)
	config.keys = {
		-- Panes
		{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
		{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
		{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
		{ key = "h", mods = "ALT|SHIFT", action = act.SplitPane({ direction = "Left", size = { Percent = 40 } }) },
		{ key = "j", mods = "ALT|SHIFT", action = act.SplitPane({ direction = "Down", size = { Percent = 40 } }) },
		{ key = "k", mods = "ALT|SHIFT", action = act.SplitPane({ direction = "Up", size = { Percent = 40 } }) },
		{ key = "l", mods = "ALT|SHIFT", action = act.SplitPane({ direction = "Right", size = { Percent = 40 } }) },
		{ key = "w", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },
		-- Tabs
		{ key = "[", mods = "ALT", action = act.ActivateTabRelative(-1) },
		{ key = "]", mods = "ALT", action = act.ActivateTabRelative(1) },
		-- Workspaces
		{ key = "UpArrow", mods = "ALT|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
		{ key = "DownArrow", mods = "ALT|SHIFT", action = act.SwitchWorkspaceRelative(1) },
		-- Navigate text quickly with alt and cmd
		{
			key = "LeftArrow",
			mods = "ALT",
			action = act.SendKey({ key = "b", mods = "ALT" }),
		},
		{
			key = "RightArrow",
			mods = "ALT",
			action = act.SendKey({ key = "f", mods = "ALT" }),
		},
		{
			key = "LeftArrow",
			mods = "SUPER",
			action = act.SendKey({ key = "a", mods = "CTRL" }),
		},
		{
			key = "RightArrow",
			mods = "SUPER",
			action = act.SendKey({ key = "e", mods = "CTRL" }),
		},
	}
end
return M
