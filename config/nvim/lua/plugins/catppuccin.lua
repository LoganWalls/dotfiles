return {
	"catppuccin/nvim",
	name = "catppuccin",
	opts = {
		flavour = "mocha",
		transparent_background = true,
		integrations = {
			cmp = false,
			fidget = true,
			mini = true,
			native_lsp = { enabled = true },
			telescope = true,
			treesitter = true,
		},
	},
}
