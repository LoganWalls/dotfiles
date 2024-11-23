return {
	{
		"folke/lazydev.nvim",
		dependencies = {
			{ "justinsgithub/wezterm-types", lazy = true },
			{ "Bilal2453/luvit-meta", lazy = true },
		},
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				{ path = "wezterm-types", mods = { "wezterm" } },
			},
			integrations = { cmp = false },
		},
	},
}
