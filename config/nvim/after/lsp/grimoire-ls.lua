---@type vim.lsp.Config
return {
	name = "grimoire-ls",
	cmd = { "/Users/logan/Projects/grimoire-ls/.venv/bin/python", "-m", "grimoire_ls.run" },
	root_markers = { ".git" },
	on_init = function(client, _)
		-- TODO: remove this once pygls sets this correctly
		if client.server_capabilities.inlineCompletionProvider == nil then
			client.server_capabilities.inlineCompletionProvider = {}
		end
	end,
}
