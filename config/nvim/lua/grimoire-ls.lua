local M = {}

M.start = function()
	vim.lsp.start({
		name = "grimoire-ls",
		cmd = { "python", "-m", "grimoire_ls.run" },
		capabilities = vim.lsp.protocol.make_client_capabilities(),
		root_dir = vim.fs.dirname(vim.fs.find({ "setup.py", "pyproject.toml" }, { upward = true })[1]),
	})
end

M.restart = function()
	local server = vim.lsp.get_clients({ name = "grimoire-ls" })[1]
	if server ~= nil then
		server.stop()
	end
	M.start()
end

return M
