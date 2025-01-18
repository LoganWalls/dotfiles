return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = "*",
	opts = {
		provider = "qwen-coder-33b",
		auto_suggestions_provider = "qwen-coder-1.5b",
		---@type AvanteProvider
		vendors = {
			["qwen-coder-33b"] = {
				__inherited_from = "openai",
				api_key_name = "",
				endpoint = "http://127.0.0.1:1234/v1",
				model = "qwen2.5-coder-32b-instruct",
			},
			["qwen-coder-1.5b"] = {
				__inherited_from = "openai",
				endpoint = "http://127.0.0.1:1234/v1",
				model = "mlx-community/qwen2.5-coder-1.5b",
			},
		},
	},
	build = "make",
	dependencies = {
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"echasnovski/mini.icons",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
