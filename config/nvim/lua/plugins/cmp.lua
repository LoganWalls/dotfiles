local config = function()
	local cmp = require("cmp")
	local kind_icons = {
		Text = "",
		Method = "󰆧",
		Function = "",
		Constructor = "",
		Field = "󰇽",
		Variable = "󰂡",
		Class = "󰠱",
		Interface = "",
		Module = "",
		Property = "󰜢",
		Unit = "",
		Value = "󰎠",
		Enum = "",
		Keyword = "󰌋",
		Snippet = "",
		Color = "󰏘",
		File = "󰈙",
		Reference = "",
		Folder = "󰉋",
		EnumMember = "",
		Constant = "󰏿",
		Struct = "",
		Event = "",
		Operator = "󰆕",
		TypeParameter = "󰅲",
		Copilot = "󱁉",
	}
	cmp.setup({
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		mapping = {
			["<C-j>"] = cmp.mapping({
				i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
				c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
			}),
			["<C-k>"] = cmp.mapping({
				i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
				c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
			}),
			["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
			["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
			["<C-y>"] = cmp.config.disable, -- Remove the default `<C-y>` mapping.
			["<C-e>"] = cmp.mapping({
				i = cmp.mapping.abort(),
				c = cmp.mapping.close(),
			}),
			["<C-space>"] = cmp.config.disable,
			-- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			["<CR>"] = cmp.mapping({
				i = cmp.mapping.confirm({ select = true }),
				c = cmp.mapping.confirm({ select = false }),
			}),
		},
		formatting = {
			format = function(entry, vim_item)
				vim_item.kind = kind_icons[vim_item.kind]
				if entry.source.name == "nvim_lsp" and entry.source.source.client.name == "grimoire-ls" then
					vim_item.kind = kind_icons["Copilot"]
				end
				-- Uncomment to see which sources provide each completion (useful for debugging)
				-- vim_item.menu = entry.source.name
				return vim_item
			end,
		},
		experimental = {
			ghost_text = true,
		},
		sources = {
			{ name = "copilot" },
			{ name = "nvim_lsp" },
			{ name = "nvim_lsp_signature_help" },
			{ name = "luasnip" },
			{
				name = "treesitter",
				entry_filter = function(entry)
					local kind = require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
					for _, v in ipairs({ "Text", "Comment" }) do
						if v == kind then
							return false
						end
					end
					return true
				end,
			},
			{ name = "path" },
			{ name = "nvim_lua" },
			{ name = "omni" },
			{ name = "spell" },
		},
		window = {
			completion = cmp.config.window.bordered({
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
				scrollbar = false,
			}),
			documentation = cmp.config.window.bordered({
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
			}),
		},
	})

	-- Manual completion for AI
	vim.keymap.set("i", "<C-space>", function()
		require("grimoire-ls").enable_completion(true)
		cmp.complete({
			config = {
				sources = {
					{
						name = "nvim_lsp",
						entry_filter = function(entry)
							return entry.source.source.client.name == "grimoire-ls"
						end,
					},
				},
				view = {
					entries = { name = "wildmenu", separator = " " },
				},
				formatting = {
					format = function(_, vim_item)
						vim_item.abbr = ""
						return vim_item
					end,
				},
			},
		})
	end)
	cmp.event:on("complete_done", function()
		require("grimoire-ls").enable_completion(false)
	end)

	-- Completion for search and command line
	cmp.setup.cmdline({ "/", "?" }, {
		sources = {
			{ name = "buffer" },
		},
	})
	cmp.setup.cmdline(":", {
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{ name = "cmdline" },
		}),
	})

	-- Separate settings for writing
	local writing_sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "spell" },
		{ name = "emoji" },
		{ name = "latex_symbols" },
	}

	local writing_filetypes = {
		"text",
		"markdown",
		"org",
		"neorg",
		"latex",
		"html",
	}

	for _, t in pairs(writing_filetypes) do
		cmp.setup.filetype(t, {
			sources = cmp.config.sources(writing_sources),
		})
	end
end

return {
	{
		"LoganWalls/nvim-cmp",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-omni",
			"ray-x/cmp-treesitter",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
			"f3fora/cmp-spell",
			"kdheepak/cmp-latex-symbols",
		},
		config = config,
	},
}
