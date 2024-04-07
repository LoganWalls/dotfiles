local set = vim.opt_local
vim.bo.commentstring = "// %s"

set.spell = true -- Enable spellchecking
vim.keymap.set("n", "<Leader>lp", function()
	-- Pin `main.typ` as the main file if it exists
	local main_file = vim.fs.find("main.typ", { path = vim.fn.getcwd(), type = "file" })[1]
	if main_file ~= nil then
		vim.lsp.buf.execute_command({
			command = "typst-lsp.doPinMain",
			arguments = { vim.uri_from_fname(main_file) },
		})
		print("Pinned to " .. vim.uri_from_fname(main_file))
	end
end)
