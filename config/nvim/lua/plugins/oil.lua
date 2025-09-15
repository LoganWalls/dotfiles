return {
	"stevearc/oil.nvim",
	opts = {
		delete_to_trash = true,
	},
	config = function(opts)
		require("oil").setup(opts)
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end,
	dependencies = { "echasnovski/mini.nvim" },
}
