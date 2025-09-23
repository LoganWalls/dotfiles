local FileWatcher = {}
FileWatcher.__index = FileWatcher

--- Creates a new file watcher.
---
--- See `:help uv.fs_event_start()` for documentation on `flags` and
--- `callback`.
---
---@param path string
---@param flags table
---@param callback function
function FileWatcher.new(path, flags, callback)
	local state = {
		fs_event = vim.uv.new_fs_event(),
	}

	vim.uv.fs_event_start(state.fs_event, path, flags, vim.schedule_wrap(callback))

	return setmetatable(state, FileWatcher)
end

--- Stops the file watcher.
function FileWatcher:stop()
	vim.uv.fs_event_stop(self.fs_event)
	self.fs_event = nil
end

return FileWatcher
