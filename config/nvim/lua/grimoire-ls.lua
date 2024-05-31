local M = {}

M.start = function()
	vim.lsp.start({
		name = "grimoire-ls",
		cmd = { "python", "-m", "grimoire_ls.run" },
		root_dir = vim.fn.getcwd(),
	})
end

M.restart = function()
	local server = M.get_client()
	if server ~= nil then
		server.stop()
	end
	M.start()
end

M.get_client = function()
	local clients = vim.lsp.get_clients({ name = "grimoire-ls" })
	if clients then
		return clients[1]
	end
end

M.enable_completion = function(enable)
	local client = M.get_client()
	if not client then
		return
	end

	local current_settings = client.server_capabilities.completionProvider
	if current_settings then
		M._completion = current_settings
	end

	if enable then
		client.server_capabilities.completionProvider = M._completion
	else
		client.server_capabilities.completionProvider = false
	end
end

return M
