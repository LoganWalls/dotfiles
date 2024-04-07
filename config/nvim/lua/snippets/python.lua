local ls = require("luasnip")
local f = ls.function_node
local t = ls.text_node
local i = ls.insert_node
local l = require("luasnip.extras").lambda
local postfix = require("luasnip.extras.postfix").postfix
local postfix_wrap = require("snippets.common").postfix_wrap

local function auto_import(name, alias, from)
	local final_name = alias or name
	local suffix = name .. (alias ~= nil and (" as " .. alias) or "")

	local function do_auto_import()
		local prefix = from and (from .. " import") or "import"
		local line_num = 0
		local lines = vim.api.nvim_buf_get_lines(0, 0, vim.fn.line("."), false)
		for n, line in ipairs(lines) do
			if vim.startswith(line, "import ") or vim.startswith(line, "from ") then
				-- Check if the import already exists.
				-- Search specifically for the suffix `foo as bar` to cover
				-- the `import blah, foo as bar, blah` case.
				if string.find(line, suffix, 1, true) then
					return final_name
				end
				line_num = n
			end
		end
		vim.api.nvim_buf_set_lines(0, line_num, line_num, false, { prefix .. " " .. suffix, "" })
		return final_name
	end

	return ls.snippet({
		name = final_name,
		trig = final_name,
		dscr = "Auto-import " .. suffix,
		docstring = "",
		snippetType = "snippet",
	}, { f(do_auto_import) })
end

local foreach = postfix(".for", {
	t("for "),
	i(1, "x"),
	t(" in "),
	l(l.POSTFIX_MATCH .. ":"),
	t({ "", string.rep(" ", vim.bo.tabstop) }),
	i(0, "pass"),
})

local foritems = postfix(".foritems", {
	t("for "),
	i(1, "k"),
	t(", "),
	i(2, "v"),
	t(" in "),
	l(l.POSTFIX_MATCH .. ".items():"),
	t({ "", string.rep(" ", vim.bo.tabstop) }),
	i(0, "pass"),
})

local type_ignore = ls.snippet("#ti", { t("# type: ignore") })

return {
	postfix_wrap("all"),
	postfix_wrap("any"),
	postfix_wrap("enumerate"),
	postfix_wrap("list"),
	postfix_wrap("len"),
	postfix_wrap("tuple"),
	postfix_wrap("print"),
	auto_import("itertools", "it"),
	auto_import("numpy", "np"),
	auto_import("pandas", "pd"),
	auto_import("polars", "pl"),
	auto_import("equinox", "eqx"),
	auto_import("altair", "alt"),
	auto_import("numpy", "jnp", "from jax"),
	foreach,
	foritems,
	type_ignore,
}
