vim.bo.tabstop = 4
vim.b.slime_cell_delimiter = "# %%"

require("snippets.common").enable_ft("python")
require("ai-lsp").start()
