return {
	"milanglacier/minuet-ai.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function(_, opts)
		require("minuet").setup(opts)
		vim.cmd([[Minuet change_preset local]])
	end,

	opts = {
		blink = {
			enable_auto_complete = false,
		},
		cmp = {
			enable_auto_complete = false,
		},
		virtualtext = {
			auto_trigger_ft = {},
			keymap = {
				accept = "<c-cr>",
				accept_line = "<c-;>",
				next = "<c-g>",
				dismiss = "<c-e>",
			},
		},

		presets = {
			["local"] = {
				n_completions = 1,
				context_window = 8192,
				provider = "openai_fim_compatible",
				provider_options = {
					openai_fim_compatible = {
						name = "LMStudio",
						end_point = "http://127.0.0.1:1234/v1/completions",
						api_key = function()
							return "sk-xxxx"
						end,
						model = "mlx-community/qwen2.5-coder-1.5b",
						stream = true,
						optional = {
							max_tokens = 200,
							top_p = 0.9,
						},
						template = {
							prompt = function(context_before_cursor, context_after_cursor, _)
								return "<|fim_prefix|>"
									.. context_before_cursor
									.. "<|fim_suffix|>"
									.. context_after_cursor
									.. "<|fim_middle|>"
							end,
							suffix = false,
						},
					},
				},
			},
		},
	},
}
