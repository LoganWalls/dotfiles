local config = function()
	local capabilities = require("cmp_nvim_lsp").default_capabilities()
	local lspconfig = require("lspconfig")

	-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
	local servers = {
		"jsonls",
		"julials",
		"dockerls",
		"html",
		"cssls",
		"eslint",
		"bufls",
		"pyright",
		"ocamllsp",
		"uiua",
	}
	for _, lsp in ipairs(servers) do
		lspconfig[lsp].setup({
			capabilities = capabilities,
		})
	end

	lspconfig.typst_lsp.setup({
		capabilities = capabilities,
	})

	lspconfig.nil_ls.setup({
		settings = {
			["nil"] = {
				formatting = {
					command = { "alejandra" },
				},
			},
		},
	})

	lspconfig.lexical.setup({
		capabilities = capabilities,
		cmd = { "lexical" },
	})

	lspconfig.ruff_lsp.setup({
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- Disable hover in favor of Pyright
			client.server_capabilities.hoverProvider = false
		end,
	})

	lspconfig.tsserver.setup({
		capabilities = capabilities,
		root_dir = lspconfig.util.root_pattern("package.json"),
	})

	lspconfig.lua_ls.setup({
		capabilities = capabilities,
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = "LuaJIT",
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { "vim" },
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = {
						vim.api.nvim_get_runtime_file("", true),
						vim.fn.stdpath("config") .. "/lua",
					},
					checkThirdParty = false,
				},
				telemetry = { enable = false },
				format = { enable = false }, -- Disable formatting since we use stylua
			},
		},
	})

	-- Styling
	local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig_util_open_floating_preview(contents, syntax, opts, ...)
	end
end

local null_ls_config = function()
	local null_ls = require("null-ls")

	null_ls.setup({
		sources = {
			--shell
			null_ls.builtins.diagnostics.shellcheck,
			null_ls.builtins.code_actions.shellcheck,
		},
	})
end

return {
	{
		"neovim/nvim-lspconfig",
		config = config,
		dependencies = {
			{ "jose-elias-alvarez/null-ls.nvim", dependencies = { "nvim-lua/plenary.nvim" }, config = null_ls_config },
		},
	},
}
