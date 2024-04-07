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

local wk = require("which-key")
local qf = require("quickfix")

wk.register({
	K = { vim.lsp.buf.hover, "Show hover documentation" },
	H = { "^", "Move beginning of line" },
	L = { "$", "Move end of line" },
	["<leader>"] = {
		a = { vim.lsp.buf.code_action, "Code action" },
		r = { vim.lsp.buf.rename, "Rename symbol" },
		d = {
			d = { vim.diagnostic.open_float, "Display problem details" },
			n = { vim.diagnostic.goto_next, "Go to next problem" },
			p = { vim.diagnostic.goto_prev, "Go to previous problem" },
		},
		F = {
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			"Format current buffer",
		},
		q = {
			q = {
				function()
					qf.toggle(function()
						require("telescope.builtin").quickfixhistory()
					end)
				end,
				"Toggle the quickfix list",
			},
			d = {
				function()
					qf.delete_item(qf.current_item().idx)
				end,
				"Delete current buffer from quickfix",
			},
		},
	},
	["<c-j>"] = { qf.wrapping_next, "Next quickfix item" },
	["<c-k>"] = { qf.wrapping_prev, "Previous quickfix item" },
})
wk.register({ ["<leader>"] = { a = { vim.lsp.buf.code_action, "Code action" } } }, { mode = "x" })

-- Allow hjkl movement in insert mode (including cmp menus).
wk.register({
	["<c-h>"] = { "<Left>", "Move left" },
	["<c-j>"] = { "<Down>", "Move down" },
	["<c-k>"] = { "<Up>", "Move up" },
	["<c-l>"] = { "<Right>", "Move right" },
}, { mode = "i" })

-- SLIME
wk.register({
	["<leader><cr>"] = { "<Plug>SlimeSendCell<cr>g]c2j", "Send cell to REPL" },
}, { mode = "n", noremap = false })
wk.register({
	["<leader><cr>"] = { "<Plug>SlimeRegionSend", "Send region to REPL" },
}, { mode = "x", noremap = false })
