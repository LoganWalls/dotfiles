local map = function(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Unbind the default commands for space and return.
map("", " ", "<NOP>")

-- Yank to end of line
map("n", "Y", "y$")

-- Break long inserts into multiple undo sequences.
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", "!", "!<c-g>u")
map("i", "?", "?<c-g>u")

-- Automatically reselect visual selection after indenting
map("v", ">", ">gv")
map("v", "<", "<gv")

-- Delete without saving to register
vim.keymap.set({ "x" }, "D", '"_d')

local wk = require("which-key")
local qf = require("quickfix")

wk.add({
	{ "K", vim.lsp.buf.hover, desc = "Show hover documentation" },
	{ "H", "^", desc = "Move beginning of line" },
	{ "L", "$", desc = "Move end of line" },
	{ "<leader>a", vim.lsp.buf.code_action, desc = "Code action" },
	{ "<leader>r", vim.lsp.buf.rename, desc = "Rename symbol" },
	{ "<leader>dd", vim.diagnostic.open_float, desc = "Display problem details" },
	{ "<leader>dn", vim.diagnostic.goto_next, desc = "Go to next problem" },
	{ "<leader>dp", vim.diagnostic.goto_prev, desc = "Go to previous problem" },
	{
		"<leader>F",
		function()
			require("conform").format({ async = true, lsp_fallback = true })
		end,
		desc = "Format current buffer",
	},
	{
		"<leader>qq",

		function()
			qf.toggle(function()
				require("telescope.builtin").quickfixhistory()
			end)
		end,
		desc = "Toggle the quickfix list",
	},
	{
		"<leader>qd",
		function()
			qf.delete_item(qf.current_item().idx)
		end,
		desc = "Delete current buffer from quickfix",
	},
	{ "<c-j>", qf.wrapping_next, desc = "Next quickfix item" },
	{ "<c-k>", qf.wrapping_prev, desc = "Previous quickfix item" },
	{ "<leader>a", vim.lsp.buf.code_action, desc = "Code action", mode = "x" },
	{ "<leader><cr>", "<Plug>SlimeSendCell<cr>g]c2j", desc = "Send cell to REPL", noremap = false },
	{ "<leader><cr>", "<Plug>SlimeRegionSend", desc = "Send region to REPL", mode = "x", noremap = false },
	-- Allow hjkl movement in insert mode (including cmp menus).
	{
		mode = "i",
		{ "<c-h>", "<Left>", desc = "Move left" },
		{ "<c-j>", "<Down>", desc = "Move down" },
		{ "<c-k>", "<Up>", desc = "Move up" },
		{ "<c-l>", "<Right>", desc = "Move right" },
	},
})
