local function set_keymap(keys, type)
	vim.keymap.set("n", keys, function()
		require("neogen").generate({ type = type })
	end, { noremap = true, silent = true })
end

return {
	"danymat/neogen",
	dependencies = "nvim-treesitter/nvim-treesitter",
	config = function()
		require("neogen").setup({ snippet_engine = "luasnip" })
		set_keymap("<Leader>gf", "func")
		set_keymap("<Leader>gF", "file")
		set_keymap("<Leader>gc", "class")
		set_keymap("<Leader>gt", "type")
	end,
}
