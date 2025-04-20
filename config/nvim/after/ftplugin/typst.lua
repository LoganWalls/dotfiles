local set = vim.opt_local
vim.bo.commentstring = "// %s"
set.textwidth = 80
set.spell = true
set.breakindent = true

vim.keymap.set("n", "<Leader>lp", function()
	-- Pin `main.typ` as the main file if it exists
	local main_file = vim.fs.find("main.typ", { path = vim.fn.getcwd(), type = "file" })[1]
	if main_file ~= nil then
		vim.lsp.buf_request_sync(0, "workspace/executeCommand", {
			command = "typst-lsp.doPinMain",
			arguments = { vim.uri_from_fname(main_file) },
		}, 1000)
		print("Pinned to " .. vim.uri_from_fname(main_file))
	end
end)
