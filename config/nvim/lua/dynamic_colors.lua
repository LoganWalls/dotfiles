local M = {}

function M.defaults()
	---@class DynamicColorsConfig
	local options = {
		path = vim.fs.joinpath(vim.fn.stdpath("config"), "colorscheme.txt"), ---@type string File containing colorscheme name
		persist_changes = true, ---Whether to persist changes to colorscheme?
		apply_on_start = true, ---Load persisted colorscheme on start?
	}
	return options
end

---@return string | nil: colorcheme name or nil if `path` does not exist
function M.load_colorscheme()
	local f = io.open(M.options.path, "r")
	local colorscheme_name = nil
	if f then
		colorscheme_name = f:read("*l")
		f:close()
	end
	return colorscheme_name
end

--- Saves the current colorscheme to disk
function M.save_colorscheme()
	vim.fn.writefile({ vim.g.colors_name }, M.options.path, "s")
end

---@param opts? DynamicColorsConfig
function M.setup(opts)
	---@type DynamicColorsConfig
	M.options = vim.tbl_deep_extend("force", M.defaults(), opts or {})
	if vim.fn.filereadable(M.options.path) == 0 then
		vim.notify(string.format("No colorscheme file found at %s\nCreating one", M.options.path), vim.log.levels.WARN)
		M.save_colorscheme()
	end

	if M.options.persist_changes then
		vim.api.nvim_create_augroup("DynamicColors", { clear = true })
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = "DynamicColors",
			desc = "Persist colorscheme to disk",
			callback = M.save_colorscheme,
		})
	end

	local uv = vim.loop
	M.handle = uv.new_fs_event()
	function M.unwatch()
		uv.fs_event_stop(M.handle)
	end
	local function callback(err)
		if err then
			error(err)
			M.unwatch()
			return
		end
		local colorscheme_name = M.load_colorscheme()
		if colorscheme_name and colorscheme_name ~= vim.g.colors_name then
			vim.schedule(function()
				vim.cmd.colorscheme(colorscheme_name)
				M.handle:stop()
				uv.fs_event_start(M.handle, M.options.path, {}, callback)
			end)
		end
	end

	if M.options.apply_on_start then
		callback()
	end

	uv.fs_event_start(M.handle, M.options.path, {}, callback)
end

return M
