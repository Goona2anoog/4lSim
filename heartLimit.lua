function IsIn(data, value)
	if data == nil then return false end
	
	for k,v in pairs(data) do
		if v == value then
			return true
		end
	end
end

function printLog(...)
	local al_dict = {}
	
	local function getPrintStr(packet)
		local str = ""
		if type(packet) == "table" then
			if al_dict[packet] then
				return "qiantao"
			end
			al_dict[packet] = true
			
			for i,v in pairs(packet) do
				if type(i) == "number" then
					local a = string.format("%s,", getPrintStr(v))
					str = str..a
				else
					local a = string.format("%s:%s,", getPrintStr(i), getPrintStr(v))
					str = str..a
				end
			end
			str = "["..str.."]"
		elseif type(packet) == "string" then
			str = '"'..packet..'"'
		else
			str = tostring(packet)
		end
		return str
	end
	
	local s = ""
	
	for i=1, select("#", ...) do
		s = s..getPrintStr(select(i, ...)).." "
	end
	
	print(s)
end

local s_score = 23815
local h_rank = 3.5
local limit = 2147483648
local h_num = 10
local i_offset, j_offset = 1, 1
local h_bonus = 100


local function run()
	for i = 1, 500 do
		for j = 1, 500 do
			if s_score*h_rank*(1+(h_bonus*(j-1)*j_offset)/100)*(h_num*i_offset*(i-1)) >= limit then
				printLog("limit! h_num, h_bonus:", h_num*i_offset*(i-1), h_bonus*(j-1)*j_offset)
				break
			end
		end
	end
end

run()
