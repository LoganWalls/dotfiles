local ls = require("luasnip")
local f = ls.function_node
local postfix = require("luasnip.extras.postfix").postfix

local M = {}

-- Enable snippets for a given filetype
M.enable_ft = function(filetype)
	require("once")(filetype .. "_snippets", function()
		ls.add_snippets(filetype, require("snippets." .. filetype))
	end)
end

-- Returns a snippet that will expand foo.name to name(foo)
M.postfix_wrap = function(name)
	return postfix({ trig = "." .. name, match_pattern = "[%S]+$" }, {
		f(function(_, parent)
			return name .. "(" .. parent.snippet.env.POSTFIX_MATCH .. ")"
		end, {}),
	})
end

return M
