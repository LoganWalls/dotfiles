local set = vim.opt_local

set.spell = true -- Enable spellchecking
set.wrap = true -- Don't wrap lines
set.linebreak = true -- Don't wrap in the middle of a word
set.breakindent = true -- Wrapped lines preserve indentation

local keymap_opts = { noremap = true, buffer = 0 }
local jk_opts = vim.tbl_extend("force", keymap_opts, { expr = true })
-- Open / move in PDF viewer to the redered counterpart of the cursor's current position
vim.keymap.set("n", "<leader>v", function()
	vim.cmd("VimtexView")
end, keymap_opts)
vim.keymap.set("n", "<leader>c", function()
	vim.cmd("VimtexCompile")
end, keymap_opts)

-- Navigate as if soft-wrapped lines are actually hard-wrapped
vim.keymap.set({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", jk_opts)
vim.keymap.set({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", jk_opts)
vim.keymap.set("n", "I", "g_i", keymap_opts)
vim.keymap.set("n", "A", "g$a", keymap_opts)
vim.keymap.set("n", "Y", "yg$", keymap_opts)
vim.keymap.set("n", "D", "dg$", keymap_opts)
vim.keymap.set("n", "o", "g$a<cr>", keymap_opts)
vim.keymap.set("n", "O", "g_i<cr>", keymap_opts)

-- Make colors less distracting
local hl_groups = {
	"Statement",
	"Include",
	"Special",
}
for _, group in pairs(hl_groups) do
	vim.api.nvim_set_hl(0, group, { link = "Comment" })
end
