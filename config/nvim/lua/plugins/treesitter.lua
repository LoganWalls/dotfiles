local config = function()
	require("nvim-treesitter.install").compilers = { "gcc-12", "gcc" }
	require("nvim-treesitter").setup({
		auto_install = true,
		ensure_installed = {
			"bash",
			"bibtex",
			"c",
			"css",
			"csv",
			"elixir",
			"html",
			"javascript",
			"jinja",
			"json",
			"julia",
			"lua",
			"nu",
			"ocaml",
			"python",
			"query",
			"r",
			"rust",
			"scss",
			"scheme",
			"sql",
			"toml",
			"tsx",
			"typescript",
			"typst",
			"vim",
			"vimdoc",
			"yaml",
		},
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn",
				node_incremental = "grn",
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},
		playground = {
			enable = true,
			disable = {},
			updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
			persist_queries = false, -- Whether the query persists across vim sessions
			keybindings = {
				toggle_query_editor = "o",
				toggle_hl_groups = "i",
				toggle_injected_languages = "t",
				toggle_anonymous_nodes = "a",
				toggle_language_display = "I",
				focus_language = "f",
				unfocus_language = "F",
				update = "R",
				goto_node = "<cr>",
				show_help = "?",
			},
		},
	})
	require("treesitter-context").setup({
		separator = nil,
	})
	-- Use treesitter for folding
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-context",
		},
		lazy = false,
		build = ":TSUpdate",
		config = config,
	},
}
