local colorscheme_path = vim.fs.joinpath(vim.fn.stdpath("config"), "lua/colorscheme.lua")

local function reload_colorscheme()
	package.loaded["colorscheme"] = nil -- Prevent caching
	local colorscheme = require("colorscheme")
	if colorscheme == nil then
		error("No colorscheme lua file found at:" .. colorscheme_path)
	end
	package.loaded["catppuccin"] = nil -- Prevent caching
	require("catppuccin").setup({
		flavour = "mocha",
		transparent_background = true,
		integrations = {
			cmp = false,
			fidget = true,
		},
		color_overrides = {
			all = colorscheme.colors,
		},
	})
end

local function config()
	reload_colorscheme()
	-- Do not set colorscheme here, it is set for the first time at the end of `style.lua`
	local watcher = require("file_watcher").new(colorscheme_path, {}, function(err, _filename, _events)
		if err then
			error("failed to watch for colorscheme changes: " .. err)
		end
		reload_colorscheme()
		vim.cmd.colorscheme("catppuccin")
	end)

	vim.api.nvim_create_user_command("DeleteWatcher", function()
		watcher:stop()
		vim.notify("stopped watcher")
	end, {})
end

return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = config,
}
