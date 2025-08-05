return {
	"lukas-reineke/headlines.nvim",
	dependencies = "nvim-treesitter/nvim-treesitter",
	opts = {},
	-- config = function()
	--   require("headlines").setup({
	--     typst = {
	--       query = vim.treesitter.query.parse(
	--         "typst",
	--         [[
	--           (heading) @headline
	--           (raw_blck) @codeblock
	--         ]]
	--       ),
	--       headline_highlights = { "Headline" },
	--       bullet_highlights = {
	--         "@text.title.1.marker.markdown",
	--         "@text.title.2.marker.markdown",
	--         "@text.title.3.marker.markdown",
	--         "@text.title.4.marker.markdown",
	--         "@text.title.5.marker.markdown",
	--         "@text.title.6.marker.markdown",
	--       },
	--       bullets = { "◉", "○", "✸", "✿" },
	--       codeblock_highlight = "CodeBlock",
	--       dash_highlight = "Dash",
	--       dash_string = "-",
	--       quote_highlight = "Quote",
	--       quote_string = "┃",
	--       fat_headlines = true,
	--       fat_headline_upper_string = "▃",
	--       fat_headline_lower_string = "🬂",
	--     },
	--   })
	-- end
}
