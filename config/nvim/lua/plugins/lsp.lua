local config = function()
	local capabilities = require("cmp_nvim_lsp").default_capabilities()
	local lspconfig = require("lspconfig")

	-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
	local servers = {
		"buf_ls",
		"cssls",
		"dockerls",
		"eslint",
		"html",
		"jsonls",
		"julials",
		"ocamllsp",
		"pyright",
		"taplo",
		"uiua",
	}
	for _, lsp in ipairs(servers) do
		lspconfig[lsp].setup({
			capabilities = capabilities,
		})
	end

	lspconfig.tinymist.setup({
		capabilities = capabilities,
		settings = {
			formatterMode = "typstyle",
		},
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

	lspconfig.ruff.setup({
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- Disable hover in favor of Pyright
			client.server_capabilities.hoverProvider = false
		end,
	})

	lspconfig.ts_ls.setup({
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

	vim.keymap.set("n", "<leader>ll", function()
		vim.cmd("LspLog")
	end)
	vim.keymap.set("n", "<leader>li", function()
		vim.cmd("LspInfo")
	end)
end

return {
	{
		"neovim/nvim-lspconfig",
		config = config,
	},
}
