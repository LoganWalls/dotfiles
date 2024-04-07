local M = {}

M.current_item = function()
	return vim.fn.getqflist({ idx = 0, size = 0 })
end

M.wrapping_move = function(count)
	local qf_info = M.current_item()
	local size = qf_info.size

	if size == 0 then
		return
	end

	local idx = qf_info.idx
	local num = (idx + size + count) % size

	if num == 0 then
		num = size
	end

	vim.cmd(tostring(num) .. "cc")
end

M.wrapping_prev = function()
	M.wrapping_move(-1)
end

M.wrapping_next = function()
	M.wrapping_move(1)
end

M.delete_item = function(index)
	local qfl = vim.fn.getqflist()
	table.remove(qfl, index)
	vim.fn.setqflist(qfl, "r")
end

M.toggle = function(on_empty)
	local qf_exists = false
	for _, win in pairs(vim.fn.getwininfo()) do
		if win["quickfix"] == 1 then
			qf_exists = true
		end
	end
	if qf_exists == true then
		vim.cmd.cclose()
		return
	end
	if vim.tbl_isempty(vim.fn.getqflist()) then
		if on_empty ~= nil then
			on_empty()
		end
	else
		vim.cmd.copen()
	end
end

return M
