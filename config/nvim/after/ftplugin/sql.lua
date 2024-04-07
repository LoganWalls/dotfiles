vim.bo.commentstring = "-- %s"
require("cmp").setup.buffer({
	sources = {
		{ name = "vim-dadbod-completion" },
		{ name = "buffer" },
	},
})
