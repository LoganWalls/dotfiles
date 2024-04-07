local config = function()
	local ls = require("luasnip")
	ls.config.set_config({
		history = true,
		update_events = "TextChanged,TextChangedI",
	})

	-- Keybindings for jump navigation
	for _, m in pairs({ "i", "s" }) do
		require("which-key").register({
			["<c-n>"] = {
				function()
					if ls.expand_or_jumpable() then
						ls.expand_or_jump()
					end
				end,
				"Next LuaSnip position",
			},
			["<c-p>"] = {
				function()
					if ls.jumpable(-1) then
						ls.jump(-1)
					end
				end,
				"Previous LuaSnip position",
			},
		}, { mode = m, silent = true })
	end
	require("luasnip.loaders.from_vscode").lazy_load()
end
return {
	{
		"L3MON4D3/LuaSnip",
		version = "^2",
		dependencies = "rafamadriz/friendly-snippets",
		config = config,
	},
}
