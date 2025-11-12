vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = "󰋗 ",
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

		vim.api.nvim_set_hl(0, "TreesitterContext", { link = "Visual" })
		vim.api.nvim_set_hl(0, "TreesitterContextBottom", {})

		-- Statusline
		local function get_hl_hex(name)
			local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
			if not ok or not hl then
				return nil
			end
			if hl.foreground then
				hl.foreground = string.format("#%06x", hl.foreground)
			end
			if hl.background then
				hl.background = string.format("#%06x", hl.background)
			end
			if hl.special then
				hl.special = string.format("#%06x", hl.special)
			end
			return hl
		end

		local normal_hl = get_hl_hex("Normal")
		if normal_hl ~= nil then
			for _, mode_name in pairs(vim.fn.getcompletion("MiniStatuslineMode", "highlight")) do
				local mode_hl = get_hl_hex(mode_name)
				if mode_hl ~= nil then
					mode_hl.foreground = mode_hl.background or normal_hl.foreground
					mode_hl.background = normal_hl.background
					vim.api.nvim_set_hl(0, mode_name, mode_hl)
				end
			end
		end

		vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { link = "Normal" })
		vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { link = "Normal" })
		vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo", { link = "Normal" })
	end,
})

vim.cmd.colorscheme("catppuccin")
