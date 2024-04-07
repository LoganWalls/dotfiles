local set = vim.opt_local

set.spell = true -- Enable spellchecking
set.wrap = true -- Don't wrap lines
set.linebreak = true -- Don't wrap in the middle of a word
set.breakindent = true -- Wrapped lines preserve indentation
-- set.breakindentopt = "sbr" -- Show symbol after broken lines
-- set.showbreak = "⮑ "     -- Symbol to indicate line wrap

-- Navigate as if soft-wrapped lines are actually hard-wrapped
vim.api.nvim_buf_set_keymap(0, "n", "j", "gj", { noremap = true })
vim.api.nvim_buf_set_keymap(0, "n", "k", "gk", { noremap = true })
