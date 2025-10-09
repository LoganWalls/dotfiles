-- Unbind the default commands for space and return.
vim.keymap.set("", " ", "<NOP>")

-- Yank to end of line
vim.keymap.set("n", "Y", "y$")

-- Break long inserts into multiple undo sequences.
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", "!", "!<c-g>u")
vim.keymap.set("i", "?", "?<c-g>u")

-- hjkl in insert mode
vim.keymap.set("i", "<c-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<c-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<c-k>", "<Up>", { desc = "Move up" })
vim.keymap.set("i", "<c-l>", "<Right>", { desc = "Move right" })

-- Automatically reselect visual selection after indenting
vim.keymap.set("x", ">", ">gv")
vim.keymap.set("x", "<", "<gv")

-- Substitution
vim.keymap.set("n", "<c-s>", [[<esc>:%s/\v]], { desc = "Substitute buffer-wide" })
vim.keymap.set("x", "<c-s>", [[<esc>:'<,'>s/\v]], { desc = "Substitute in selection" })

-- Delete without saving to register
vim.keymap.set("x", "D", '"_d')

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover documentation" })
vim.keymap.set("n", "H", "^", { desc = "Move beginning of line" })
vim.keymap.set("n", "L", "$", { desc = "Move end of line" })
vim.keymap.set({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Diagnostic details" })
vim.keymap.set("n", "<leader>dn", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>dp", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" })

-- Quickfix mappings
local qf = require("quickfix")
vim.keymap.set("n", "<leader>qq", function()
	qf.toggle(function()
		require("telescope.builtin").quickfixhistory()
	end)
end, { desc = "Toggle the quickfix list" })

vim.keymap.set("n", "<leader>qd", function()
	qf.delete_item(qf.current_item().idx)
end, { desc = "Delete current buffer from quickfix" })

vim.keymap.set("n", "<c-j>", qf.wrapping_next, { desc = "Next quickfix item" })
vim.keymap.set("n", "<c-k>", qf.wrapping_prev, { desc = "Previous quickfix item" })
