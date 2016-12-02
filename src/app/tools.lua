cc.exports.cclog = function(...)
	print(string.format(...))
end

cc.exports.print_table = function(t)
	local function parse_arr(key, tab)
		local str = ''

		for k, v in pairs(tab) do
			if type(v) == "table" then
				str = str .. key ..'.' .. parse_arr(k, v)
			else
				str = str .. key .. '.' .. k .. ' ' .. v .. '\r'
			end
		end
		return str
	end

	local str = '\r\n'
	for k, v in pairs(t) do
		if type(v) == "table" then
			str = str .. parse_arr(k, v)
		else
			str = str .. k .. ' ' .. (v) .. '\r'
		end	
	end	
	cclog(str)
end