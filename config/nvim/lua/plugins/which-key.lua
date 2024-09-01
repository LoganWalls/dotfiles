return {
	{
		"folke/which-key.nvim",
		lazy = true,
		config = function()
			require("which-key").setup({
				win = { border = "rounded" },
			})
			-- Theme
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "NormalFloat" })
		end,
	},
}
