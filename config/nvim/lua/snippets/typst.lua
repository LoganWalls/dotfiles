local ls = require("luasnip")
local t = ls.text_node
local i = ls.insert_node

local pcite = ls.snippet("pcite", { t("#cite("), i(0, "<key>"), t([[, form: "prose")]]) })

return {
	pcite,
}
