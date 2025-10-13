local set = vim.opt_local

set.textwidth = 80
set.breakindent = true -- Wrapped lines preserve indentation
-- set.breakindentopt = "sbr" -- Show symbol after broken lines
-- set.showbreak = "⮑ "     -- Symbol to indicate line wrap

local is_floating = vim.api.nvim_win_get_config(0).relative ~= ""
if not is_floating then
	set.spell = true -- Enable spellchecking
end
