local ra_settings = {
	imports = {
		granularity = {
			group = "module",
		},
		prefix = "self",
	},
	cargo = {
		features = "all",
		buildScripts = {
			enable = true,
		},
	},
	procMacro = {
		enable = true,
	},
	checkOnSave = true,
	check = {
		command = "clippy",
		features = "all",
		invocationLocation = "workspace",
		extraArgs = { "--tests" },
	},
	files = {
		excludeDirs = { ".direnv" },
	},
}

if vim.fn.executable("leptosfmt") == 1 then
	ra_settings.rustfmt = { overrideCommand = { "leptosfmt", "--stdin", "--rustfmt" } }
end

vim.g.rustaceanvim = {
	server = {
		cmd = { "rust-analyzer" },
		standalone = true,
		settings = {
			["rust-analyzer"] = ra_settings,
		},
	},
}

return {
	"mrcjkb/rustaceanvim",
	version = "^4",
	ft = "rust",
}
