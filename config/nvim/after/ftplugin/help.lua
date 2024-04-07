-- Make help open full screen
vim.cmd.wincmd("_")

-- Close buffer with q
vim.keymap.set("n", "q", ":bd<cr>", { buffer = 0 })
