return {
	"catppuccin/nvim",
	name = "catppuccin",
	opts = {
		flavour = "mocha",
		transparent_background = true,
		integrations = {
			cmp = true,
			fidget = true,
			flash = true,
			gitsigns = true,
			mini = true,
			native_lsp = { enabled = true },
			telescope = true,
			treesitter = true,
			which_key = true,
		},
	},
}
