local completion_endpoint = "http://localhost:7777"
return {
	"zbirenbaum/copilot.lua",
	dependencies = {
		{
			"zbirenbaum/copilot-cmp",
			config = function()
				require("copilot_cmp").setup()
			end,
		},
	},
	opts = {
		suggestion = { enabled = true },
		panel = { enabled = false },
		server_opts_overrides = {
			settings = {
				advanced = {
					debug = {
						overrideProxyUrl = completion_endpoint,
						testOverrideProxyUrl = completion_endpoint,
					},
				},
			},
		},
	},
}
