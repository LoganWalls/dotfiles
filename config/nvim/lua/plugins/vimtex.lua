vim.g.vimtex_imaps_enabled = 0
vim.g.vimtex_fold_enabled = 1

vim.g.vimtex_view_method = "skim"
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_latexmk_engines = { _ = "-xelatex" }

-- Filter unhelpful warnings from the quickfix list
vim.g.vimtex_quickfix_ignore_filters = {
	"Underfull \\\\hbox",
	"Underfull \\\\vbox",
	"Overfull \\\\hbox",
	"Overfull \\\\vbox",
	"LaTeX Warning: .\\+ float specifier changed to",
	"LaTeX hooks Warning",
	"Package hyperref Warning: Token not allowed in a PDF string",
}

-- local function config()
--   -- Refocus terminal after an inverse search
--   vim.api.nvim_create_autocmd("VimtexEventViewReverse", {
--     group = vim.api.nvim_create_augroup("VimtexInverseSearchFocusNvim", { clear = true }),
--     buffer = 0,
--     callback = function() vim.cmd("silent !open -a WezTerm.app") end,
--   })
-- end

return { "lervag/vimtex" }
