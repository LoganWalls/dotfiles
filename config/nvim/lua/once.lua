ALREADY_RAN = {}

return function(key, f)
	if ALREADY_RAN[key] ~= nil then
		return
	end
	ALREADY_RAN[key] = true
	f()
end
