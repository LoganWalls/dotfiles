local set = vim.opt

-- Misc
set.termguicolors = true -- Make colors work with kitty
set.hidden = true -- Persist buffers in the background instead of unloading them
set.mouse = "a" -- Enable mouse interaction (I know, I know...)
set.clipboard = "unnamedplus" -- Use system clipboard
set.showmode = false -- Don't print mode in cmd (redundant with modeline)
set.undofile = true -- Persist undo history between sessions
set.path:append("**") -- Allow tab-complete for file-related commands
set.spelllang = { "en" } -- Languages for spell checking
set.laststatus = 3 -- Use global statusline

-- Lines and scrolling
set.relativenumber = true -- Use relative line numbers
set.number = true -- Display current line number at zero
set.wrap = false -- Don't wrap lines
set.scrolloff = 8 -- Scroll so that cursor is always at least 8 lines from top/bottom

-- Search
set.hlsearch = false -- Don't leave search results highlighted after searching
set.incsearch = true -- Highlight as a search is typed
set.grepprg = "rg --vimgrep  --no-heading --smart-case" -- Use ripgrep for grep-ing
set.grepformat = "%f:%l:%c:%m" -- ^

-- Indentation
set.autoindent = true -- Follow previous line's indent when wrapping
set.tabstop = 2 -- Tabs are 2 spaces wide
set.shiftwidth = 0 -- Use tabstop value
set.softtabstop = 0 -- Use tabstop value
set.expandtab = true -- Convert tabs to spaces

-- Folding
set.foldenable = false -- No folds when opening a file.
set.foldminlines = 5 -- Only fold chunks with at least 5 lines
set.foldnestmax = 5 -- Don't nest folds more than 5 deep

-- Netrw
vim.g.netrw_banner = 0 -- No banner
vim.g.netrw_liststyle = 3 -- Tree style display

vim.filetype.add({
	extension = { typ = "typst", ua = "uiua" },
	filename = {
		[".env"] = "sh",
		[".envrc"] = "sh",
		["justfile"] = "just",
	},
})

vim.g.markdown_fenced_languages = { "ts=typescript" }
