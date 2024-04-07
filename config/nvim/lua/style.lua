vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
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
