return {
	{
		"jpalardy/vim-slime",
		config = function()
			vim.g.slime_no_mapping = true
			vim.g.slime_target = "wezterm"
			vim.g.slime_python_ipython = 1

			vim.keymap.set("x", "<leader><cr>", "<Plug>SlimeRegionSend", { desc = "Send region to REPL", remap = true })
			vim.keymap.set(
				"n",
				"<leader><cr>",
				"<Plug>SlimeSendCell<cr>g]c2j",
				{ desc = "Send cell to REPL", remap = true }
			)
		end,
	},
}
