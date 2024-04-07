local config = function()
	require("staline").setup({
		sections = {
			left = { "mode" },
			mid = { { "StalineBase", "file_name" }, { "StalineBase", "branch" } },
			right = { { "StalineBase", "lsp" } },
		},
		defaults = { true_colors = true },
		inactive_sections = {
			left = {},
			mid = {},
			right = {},
		},
	})
	vim.api.nvim_set_hl(0, "StalineBase", { link = "Normal" })
	vim.api.nvim_create_autocmd("ColorScheme", {
		desc = "Sync Staline colors with theme",
		callback = function()
			local extract_hl = require("staline.utils").extract_hl
			local conf = require("staline.config")
			conf.mode_colors = {
				["n"] = extract_hl("Function"),
				["c"] = extract_hl("Identifier"),
				["i"] = extract_hl("Keyword"),
				["ic"] = extract_hl("Keyword"),
				["s"] = extract_hl("Keyword"),
				["S"] = extract_hl("Keyword"),
				["v"] = extract_hl("Type"),
				["V"] = extract_hl("Type"),
				[""] = extract_hl("Type"),
				["t"] = extract_hl("Identifier"),
				["r"] = extract_hl("Statement"),
				["R"] = extract_hl("Statement"),
			}
		end,
	})
end

return {
	{
		"tamton-aquib/staline.nvim",
		config = config,
	},
}
