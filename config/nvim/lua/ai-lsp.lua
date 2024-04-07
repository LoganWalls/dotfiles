local M = {}

M.start = function()
	vim.lsp.start({
		name = "ai-lsp",
		cmd = { "python", "-m", "ai_lsp.server" },
		capabilities = vim.lsp.protocol.make_client_capabilities(),
		root_dir = vim.fs.dirname(vim.fs.find({ "setup.py", "pyproject.toml" }, { upward = true })[1]),
	})
end

return M
