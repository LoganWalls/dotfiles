return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	opts = {
		width = 110,
		buffers = {
			right = {
				enabled = false,
			},
			wo = {
				fillchars = "eob: ",
			},
		},
		autocmds = {
			enableOnVimEnter = true,
			reloadOnColorSchemeChange = true,
		},
	},
}
