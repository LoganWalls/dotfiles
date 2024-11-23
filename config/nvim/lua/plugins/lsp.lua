return {
	"neovim/nvim-lspconfig",
	dependencies = { "saghen/blink.cmp" },
	config = function(_, opts)
		local lspconfig = require("lspconfig")
		for server, config in pairs(opts.servers or {}) do
			config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
			lspconfig[server].setup(config)
		end

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
	end,
	opts = {
		servers = {
			buf_ls = {},
			cssls = {},
			dockerls = {},
			eslint = {},
			html = {},
			jsonls = {},
			julials = {},
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						-- workspace = {
						-- 	-- Make the server aware of Neovim runtime files
						-- 	library = {
						-- 		vim.api.nvim_get_runtime_file("", true),
						-- 		vim.fn.stdpath("config") .. "/lua",
						-- 	},
						-- 	checkThirdParty = false,
						-- },
						telemetry = { enable = false },
						format = { enable = false }, -- Disable formatting since we use stylua
					},
				},
			},
			nil_ls = {
				settings = {
					["nil"] = {
						formatting = {
							command = { "alejandra" },
						},
					},
				},
			},
			ocamllsp = {},
			pyright = {},
			ruff = {
				on_attach = function(client, _)
					-- Disable hover in favor of Pyright
					client.server_capabilities.hoverProvider = false
				end,
			},
			taplo = {},
			tinymist = {
				settings = {
					formatterMode = "typstyle",
				},
			},
			ts_ls = {},
			uiua = {},
		},
	},
}
