return {
	dir = "/Users/logan/Projects/grimoire.nvim",
	config = function()
		local grimoire = require("grimoire")
		grimoire.setup()
		vim.keymap.set("n", "<leader>lc", grimoire.connect)
		vim.keymap.set("i", "<C-s>", grimoire.request_completion)
		vim.keymap.set("i", "<C-.>", grimoire.next_completion)
		vim.keymap.set("i", "<C-,>", grimoire.prev_completion)
	end,
}
