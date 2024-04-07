-- Highlight yanked text for 200ms using the "Visual" highlight group
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
	end,
})

-- Auto-write markdown buffers when leaving them.
vim.api.nvim_create_autocmd("BufLeave", { pattern = "*.md", command = "silent! wall" })
