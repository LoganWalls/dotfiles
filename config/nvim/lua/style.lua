vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
})

require("lspconfig.ui.windows").default_options.border = "rounded"

vim.api.nvim_create_autocmd("ColorScheme", {
	desc = "Keep pop-up styles synced with colorscheme",
	callback = function()
		vim.api.nvim_set_hl(0, "FloatBorder", {})
		vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
		vim.api.nvim_set_hl(0, "LspInfoBorder", { link = "Normal" })
		vim.api.nvim_set_hl(0, "LineNr", { link = "Normal" })
		vim.api.nvim_set_hl(0, "LineNrAbove", { link = "Comment" })
		vim.api.nvim_set_hl(0, "LineNrBelow", { link = "Comment" })
		-- Style
		vim.api.nvim_set_hl(0, "TreesitterContext", { link = "Visual" })
		vim.api.nvim_set_hl(0, "TreesitterContextBottom", {})
	end,
})

vim.cmd.colorscheme("catppuccin")
