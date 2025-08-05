return {
	{
		"echasnovski/mini.nvim",
		config = function()
			-- Enhanced textobjects and pairs
			require("mini.ai").setup({
				custom_textobjects = {
					-- Notebook cell
					c = function(mode)
						local pattern = vim.fn.escape(vim.b.slime_cell_delimiter, [[\^$]])
						pattern = string.format([[^\s*\M%s]], pattern)
						-- Search backwards for a delimiter, returns 0 if none is found
						local cell_start_line = vim.fn.search(pattern, "bnW")
						if cell_start_line == 0 then
							cell_start_line = 1
						end
						-- Search forwards for a delimiter
						local cell_end_line = vim.fn.search(pattern, "nW")
						if cell_end_line == 0 then
							cell_end_line = vim.fn.line("$")
						else
							cell_end_line = cell_end_line - 1
						end

						return {
							from = { line = cell_start_line, col = 1 },
							to = { line = cell_end_line, col = math.max(vim.fn.getline(cell_end_line):len(), 1) },
						}
					end,
				},
			})

			-- Move selected text around
			require("mini.move").setup({
				mappings = {
					-- Move visual selection in Visual mode.
					left = "H",
					right = "L",
					down = "J",
					up = "K",
					-- Move current line in Normal mode
					line_left = "",
					line_right = "",
					line_down = "",
					line_up = "",
				},
			})
			require("mini.pairs").setup({
				mappings = {
					['"'] = {
						action = "closeopen",
						pair = '""',
						neigh_pattern = '[^"A-z0-9\\][^"A-z0-9\\]',
						register = {
							cr = false,
						},
					},
					["'"] = {
						action = "closeopen",
						pair = "''",
						neigh_pattern = "[^'A-z0-9\\][^'A-z0-9\\]",
						register = {
							cr = false,
						},
					},
					["`"] = {
						action = "closeopen",
						pair = "``",
						neigh_pattern = "[^`A-z0-9\\][^`A-z0-9\\]",
						register = {
							cr = false,
						},
					},
				},
			})
			require("mini.surround").setup({
				mappings = {
					add = "<leader>sa", -- Add surrounding in Normal and Visual modes
					delete = "ds", -- Delete surrounding
					find = "<leader>sf", -- Find surrounding (to the right)
					find_left = "<leader>sF", -- Find surrounding (to the left)
					highlight = "<leader>sH", -- Highlight surrounding
					replace = "cs", -- Replace surrounding
					update_n_lines = "<leader>sn", -- Update `n_lines`
					suffix_last = "l", -- Suffix to search with "prev" method
					suffix_next = "n", -- Suffix to search with "next" method
				},
			})

			require("mini.statusline").setup({
				content = {
					active = function()
						local MiniStatusline = require("mini.statusline")
						local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
						local git = MiniStatusline.section_git({ trunc_width = 40 })
						local diff = MiniStatusline.section_diff({ trunc_width = 75 })
						local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
						local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
						local filename = MiniStatusline.section_filename({ trunc_width = 140 })
						local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
						local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

						return MiniStatusline.combine_groups({
							{ hl = mode_hl, strings = { mode } },
							"%=", -- End left alignment
							"%[", -- Begin center alignment
							{ hl = "MiniStatuslineFilename", strings = { filename } },
							{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
							"%]", -- End center alignment
							{ hl = "MiniStatuslineDevinfo", strings = { git, diff } },
							"%=", -- Begin right alignment
							{ hl = "MiniStatuslineDevinfo", strings = { diagnostics, lsp } },
							{ hl = mode_hl, strings = { search } },
						})
					end,
				},
			})

			require("mini.diff").setup({})
			require("mini.git").setup({})

			local miniclue = require("mini.clue")
			miniclue.setup({
				triggers = {
					-- Leader triggers
					{ mode = "n", keys = "<Leader>" },
					{ mode = "x", keys = "<Leader>" },

					-- Built-in completion
					{ mode = "i", keys = "<C-x>" },

					-- `g` key
					{ mode = "n", keys = "g" },
					{ mode = "x", keys = "g" },

					-- Marks
					{ mode = "n", keys = "'" },
					{ mode = "n", keys = "`" },
					{ mode = "x", keys = "'" },
					{ mode = "x", keys = "`" },

					-- Registers
					{ mode = "n", keys = '"' },
					{ mode = "x", keys = '"' },
					{ mode = "i", keys = "<C-r>" },
					{ mode = "c", keys = "<C-r>" },

					-- Window commands
					{ mode = "n", keys = "<C-w>" },

					-- `z` key
					{ mode = "n", keys = "z" },
					{ mode = "x", keys = "z" },
				},

				clues = {
					-- Enhance this by adding descriptions for <Leader> mapping groups
					miniclue.gen_clues.builtin_completion(),
					miniclue.gen_clues.g(),
					miniclue.gen_clues.marks(),
					miniclue.gen_clues.registers(),
					miniclue.gen_clues.windows(),
					miniclue.gen_clues.z(),
				},
				window = {
					config = {
						width = "auto",
						border = "rounded",
					},
				},
			})
		end,
	},
}
