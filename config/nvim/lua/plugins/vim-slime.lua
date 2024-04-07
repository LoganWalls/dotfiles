return {
	{
		"jpalardy/vim-slime",
		config = function()
			vim.g.slime_no_mapping = true
			vim.g.slime_target = "wezterm"
			vim.g.slime_python_ipython = 1
		end,
	},
}
