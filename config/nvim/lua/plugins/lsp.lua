local tailwind_filetypes = {
	-- html
	"aspnetcorerazor",
	"astro",
	"astro-markdown",
	"blade",
	"clojure",
	"django-html",
	"htmldjango",
	"edge",
	"eelixir", -- vim ft
	"elixir",
	"ejs",
	"erb",
	"eruby", -- vim ft
	"gohtml",
	"gohtmltmpl",
	"haml",
	"handlebars",
	"hbs",
	"html",
	"htmlangular",
	"html-eex",
	"heex",
	"jade",
	"leaf",
	"liquid",
	"markdown",
	"mdx",
	"mustache",
	"njk",
	"nunjucks",
	"php",
	"razor",
	"rust",
	"slim",
	"twig",
	-- css
	"css",
	"less",
	"postcss",
	"sass",
	"scss",
	"stylus",
	"sugarss",
	-- js
	"javascript",
	"javascriptreact",
	"reason",
	"rescript",
	"typescript",
	"typescriptreact",
	-- mixed
	"vue",
	"svelte",
	"templ",
}

return {
	"neovim/nvim-lspconfig",
	dependencies = { "saghen/blink.cmp" },
	config = function(_, opts)
		local lspconfig = require("lspconfig")
		for server, config in pairs(opts.servers or {}) do
			config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
			lspconfig[server].setup(config)
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = tailwind_filetypes,
			callback = function(args)
				if args.match == "rust" and (vim.fn.search("^use leptos", "nw") == 0) then
					return
				end

				if vim.fn.filereadable("tailwind.config.js") then
					vim.cmd("LspStart tailwindcss")
				end
			end,
		})

		-- Styling
		local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "rounded"
			return orig_util_open_floating_preview(contents, syntax, opts, ...)
		end

		-- Keymaps
		vim.keymap.set("n", "<leader>ll", function()
			vim.cmd("LspLog")
		end, { desc = "LSP Log" })
		vim.keymap.set("n", "<leader>li", function()
			vim.cmd("LspInfo")
		end, { desc = "LSP Info" })
		vim.keymap.set("n", "<leader>lr", function()
			vim.cmd("LspRestart")
		end, { desc = "LSP Restart" })

		vim.lsp.enable("grimoire-ls")

		-- Setup inline completion for supported servers
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("MyLspOnAttach", {}),
			callback = function(args)
				local inline_completion_key = "<Tab>"
				local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
				if client:supports_method("textDocument/inlineCompletion") then
					vim.keymap.set("n", "<leader>ct", function()
						local filter = { bufnr = 0 }
						if vim.lsp.inline_completion.is_enabled(filter) then
							vim.lsp.inline_completion.enable(false, filter)
							vim.keymap.del("i", inline_completion_key)
						else
							vim.lsp.inline_completion.enable(true, filter)
							vim.keymap.set("i", inline_completion_key, function()
								if not vim.lsp.inline_completion.get(filter) then
									return inline_completion_key
								end
							end, { expr = true, desc = "Accept current inline completion candidate" })
						end
					end, { desc = "Toggle AI completion" })
				end
			end,
		})
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
			basedpyright = {},
			ruff = {},
			svelte = {},
			tailwindcss = {
				autostart = false, -- autostart handled by autocmd (defined above)
				filetypes = tailwind_filetypes,
				settings = {
					tailwindCSS = {
						experimental = {
							classRegex = {
								{
									"clsx\\(([^)]*)\\)",
									"(?:'|\"|`)([^']*)(?:'|\"|`)",
								},
							},
						},
						includeLanguages = {
							eelixir = "html-eex",
							eruby = "erb",
							htmlangular = "html",
							templ = "html",
							rust = "html",
						},
					},
				},
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
