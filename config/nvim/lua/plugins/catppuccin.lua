return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	opts = {
		flavour = "auto",
		background = {
			light = "latte",
			dark = "mocha",
		},
		transparent_background = true,
		integrations = {
			cmp = false,
			fidget = true,
		},
	},
}
