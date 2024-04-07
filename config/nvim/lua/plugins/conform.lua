return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				javascript = { { "prettier" } },
				lua = { "stylua" },
				nix = { "alejandra" },
				sh = { "shfmt" },
				typst = { "typstfmt" },
			},
			format_on_save = { timeout_ms = 400, lsp_fallback = true },
			formatters = {
				shfmt = {
					prepend_args = { "--simplify", "--case-indent", "--binary-next-line", "--space-redirects" },
				},
			},
		})
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
