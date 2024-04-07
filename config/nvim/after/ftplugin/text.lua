-- Custom Language Server
require("ai-lsp").start()

local function req()
	vim.lsp.buf_request(
		0,
		"textDocument/completion",
		vim.tbl_extend(
			"force",
			vim.lsp.util.make_position_params(),
			{ context = { triggerKind = vim.lsp.protocol.CompletionTriggerKind.Invoked } }
		),
		function(err, result)
			if err then
				print("Error: " .. vim.inspect(err))
				return
			end
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			local line_content = vim.api.nvim_get_current_line()
			local new = vim.split(line_content:sub(0, col) .. result.items[1].label .. line_content:sub(col + 1), "\n")
			vim.api.nvim_buf_set_lines(0, line - 1, line + #new - 1, false, new)
		end
	)
end

vim.keymap.set("n", "<Leader>l", req)
vim.keymap.set("i", "<C-e>", req)
