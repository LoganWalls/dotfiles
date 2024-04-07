local M = {}
-- Trigger autoformatting on save for supported LSPs
M.on_attach = function(client, bufnr)
	local callback = nil
	if client.supports_method("textDocument/formatting") then
		callback = function()
			vim.lsp.buf.format({ bufnr = bufnr })
		end
	end
	if vim.bo.formatprg ~= "" then
		callback = function()
			-- Save the cursor position so that we can restore it after formatting
			local pos = vim.api.nvim_win_get_cursor(0)
			vim.cmd("%!" .. vim.bo.formatprg)
			vim.api.nvim_win_set_cursor(0, pos)
		end
	end
	if callback then
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
			buffer = bufnr,
			callback = callback,
		})
	end
end

return M
