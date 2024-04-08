local config = function()
	local telescope = require("telescope")
	local actions = require("telescope.actions")
	local themes = require("telescope.themes")
	local builtin = require("telescope.builtin")

	local ivy = function(options)
		local defaults = themes.get_ivy({
			layout_strategy = "vertical",
			layout_config = {
				height = vim.o.lines,
				preview_height = 0.75,
				prompt_position = "top",

				-- For consistency with no-neck-pain
				anchor = "C",
				width = 110,
			},
			results_title = false,
			preview_title = false,
			borderchars = {
				preview = { " ", " ", " ", " ", " ", " ", " ", " " },
			},
		})

		return vim.tbl_deep_extend("force", defaults, options or {})
	end

	telescope.setup({
		defaults = {
			path_display = { truncate = 2 },
			prompt_prefix = "  ",
			selection_caret = "  ",
			entry_prefix = "   ",
			multi_icon = " ",
			mappings = {
				n = {
					q = actions.close,
				},
				i = {
					["<Esc>"] = actions.close,
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
					["<C-s>"] = actions.file_split,
					["<C-d>"] = actions.delete_buffer + actions.move_to_top,
				},
			},
		},
		pickers = {
			buffers = ivy(),
			find_files = ivy(),
			git_files = ivy(),
			live_grep = ivy(),
			grep_string = ivy(),
			help_tags = ivy(),
		},
		extensions = {
			["ui-select"] = { themes.get_cursor() },
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
			},
		},
	})
	telescope.load_extension("ui-select")
	telescope.load_extension("fzf")

	-- Keybindings
	require("which-key").register({
		g = {
			d = { builtin.lsp_definitions, "Go to definition" },
			r = { builtin.lsp_references, "Find references" },
		},
		["<leader>"] = {
			b = { builtin.buffers, "Find buffers" },
			D = { builtin.diagnostics, "Workspace diagnostics" },
			f = { builtin.find_files, "Find files" },
			h = { builtin.help_tags, "Find help" },
			Q = { builtin.quickfix, "Find quickfix" },
			["/"] = { builtin.live_grep, "Live GREP" },
			["?"] = { builtin.commands, "Find commands" },
		},
	}, { mode = "n", noremap = true })

	-- Theme
	vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "NormalFloat" })
	local hl_groups = {
		"TelescopeBorder",
		"TelescopePromptPrefix",
		"TelescopeMultiIcon",
	}
	for _, hl in pairs(hl_groups) do
		vim.api.nvim_set_hl(0, hl, { link = "TelescopeNormal" })
	end
end

return {
	"nvim-telescope/telescope.nvim",
	config = config,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
		},
	},
}
