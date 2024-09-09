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

function connectTable(src_table, connect_table)
	if src_table == nil or connect_table == nil then
		return
	end
	
	for i=1, #connect_table do
		table.insert(src_table, connect_table[i])
	end
	return src_table
end

local l_dict = {}
local n_dict = {}
local h_dict = {}

local total_n = 18
local bonus_n = {1, 2}
local bonus_kv = {[0] = 0, [1] = 50, [2] = 50}
local use_n = {10, 11, 12}
local use_kv = {[10] = 128, [11] = 104, [12] = 192, [13] = 18, [14] = 10}
local bonus_use_kv = {[11] = 114}
local shuffle_n = {21, 22, 23}
local shuffle_kv = {[20] = 102, [21] = 0, [22] = 0, [23] = 0}

--p1:run_t-85 lsh-70
--p2:run_t-55 lsh-80

local limit_h = 100
local limit_score_h = 70
local next_h_b = 0

local init_l, init_n, init_h = 0, 10, 8
local run_t = 80

math.randomseed(os.time())

local function init()
	l_dict = {}
	n_dict = {}
	h_dict = {}
	
	local t_dict = {}
	for i = 1, #use_n do
		table.insert(t_dict, use_n[i])
	end
	
	for i = 1, #shuffle_n do
		table.insert(t_dict, shuffle_n[i])
	end
	
	for i = 1, total_n-#shuffle_n-#use_n do
		table.insert(t_dict, bonus_n[i] or 0)
	end
	
	for i = 1, init_l do
		local ran_i = math.random(1, #t_dict)
		table.insert(l_dict, table.remove(t_dict, ran_i))
	end
	
	for i = 1, init_n do
		local ran_i = math.random(1, #t_dict)
		table.insert(n_dict, table.remove(t_dict, ran_i))
	end
	
	for i = 1, init_h do
		local ran_i = math.random(1, #t_dict)
		table.insert(h_dict, table.remove(t_dict, ran_i))
	end
	
	next_h_b = 0
	
	printLog("init fin.")
	printLog(l_dict, n_dict, h_dict)
end

local function check(h_dict)
	local n_i, u_i, s_i
	local n_u = 999999
	local n_s = 999999
	
	for i = 1, #h_dict do
		if IsIn(use_n, h_dict[i]) then
			if h_dict[i] < n_u then
				u_i = i
				n_u = h_dict[i]
			end
		elseif IsIn(shuffle_n, h_dict[i]) then
			if h_dict[i] < n_s then
				s_i = i
				n_s = h_dict[i]
			end
		elseif h_dict[i] < 10 then
			n_i = i
		end
	end
	
	if u_i then
		return u_i
	end
	
	if s_i then
		return s_i
	end
	
	if n_i then
		return n_i
	end
	
	return 1
end

local function checkAdd(add_list)
	for _, type in ipairs(add_list) do
		if type<10 then
			next_h_b = next_h_b + bonus_kv[type]
		end
	end
end

local function AddCard()
	local add_type = table.remove(n_dict, math.random(1, #n_dict))
	table.insert(h_dict, add_type)
	checkAdd({add_type})
end

local function HeartCatch(heart_num)
	if heart_num == 0 then
		return 0
	end
	
	local heart_num = math.ceil(heart_num*(1+next_h_b/100))
	next_h_b = 0
	if heart_num > limit_h then
		local l_num = limit_h
		local d_num = math.ceil((heart_num-limit_h)*0.2)
		
		if limit_h > limit_score_h then
			l_num = limit_score_h
		end
		
		heart_num = l_num + d_num
	else
		if heart_num > limit_score_h then
			heart_num = limit_score_h
		end
	end
	
	return heart_num
end

local function run()
	local collect_u, collect_s, collect_n, collect_h, collect_ruri = 0,0,0,0,0
	local collect_u_d = {}
	
	for i = 1, run_t do
		local use_i = check(h_dict)
		local u_type = h_dict[use_i]
		local heart_catch = 0
		
		if u_type < 10 then
			collect_n = collect_n + 1
			
			table.remove(h_dict, use_i)
			
			if #n_dict == 0 then
				n_dict = l_dict
				l_dict = {}
			end
			
			AddCard()
			table.insert(l_dict, u_type)
		elseif IsIn(use_n, u_type) then
			collect_u = collect_u + 1
			if collect_u_d[u_type] == nil then
				collect_u_d[u_type] = 0
			end
			
			collect_u_d[u_type] = collect_u_d[u_type] + 1
			
			--bonus
			if bonus_use_kv[u_type] then
				next_h_b = next_h_b + bonus_use_kv[u_type]
			end
			
			--heart_catch
			local v = use_kv[u_type] or 1
			heart_catch = HeartCatch(v)
			collect_h = collect_h + heart_catch
			
			table.remove(h_dict, use_i)
			
			if #n_dict == 0 then
				n_dict = l_dict
				l_dict = {}
			end
			
			AddCard()
			table.insert(l_dict, u_type)
		elseif IsIn(shuffle_n, u_type) then
			collect_s = collect_s + 1
			
			--heart_catch
			local v = shuffle_kv[u_type] or 0
			heart_catch = HeartCatch(v)
			if heart_catch > 0 then
				collect_ruri = collect_ruri + 1
			end
			collect_h = collect_h + heart_catch
			
			table.remove(h_dict, use_i)
			
			if #n_dict == 0 then
				n_dict = connectTable(l_dict, h_dict)
				h_dict = {}
				l_dict = {}
				
				for k = 1,8 do
					AddCard()
				end
			elseif #n_dict >=8 then
				l_dict = connectTable(l_dict, h_dict)
				h_dict = {}
				
				for k = 1, 8 do
					AddCard()
				end
			elseif #n_dict < 8 then
				l_dict = connectTable(l_dict, h_dict)
				h_dict = {}
				
				local t_n = #n_dict
				
				for k = 1,t_n do
					AddCard()
				end
				
				n_dict = connectTable(n_dict, l_dict)
				l_dict = {}
				
				for k = 1,8-t_n do
					AddCard()
				end
			end
			
			table.insert(l_dict, u_type)
		end
		
		printLog("i:", i)
		printLog("use_type:", u_type)
		printLog("l_dict:", l_dict)
		printLog("n_dict:", n_dict)
		printLog("h_dict:", h_dict)
		printLog("heart_catch:", heart_catch)
		printLog("next_h_b:", next_h_b)
	end
	
	printLog("collect_u:", collect_u)
	printLog("collect_s:", collect_s)
	printLog("collect_n:", collect_n)
	printLog("collect_h:", collect_h)
	printLog("collect_ruri:", collect_ruri)
	for k,v in pairs(collect_u_d) do
		printLog(k, v)
	end
	
	return collect_u,collect_n,collect_u_d,collect_h,collect_ruri
end

init()

local t = 0
local tn = 0
local th = 0
local tr = 0
local t_u_d = {}
for i = 1,100 do
	local a,b,c,d,e = run()
	t = t + a
	tn = tn + b
	th = th + d
	tr = tr + e
	
	for k,v in pairs(c) do
		if t_u_d[k] == nil then
			t_u_d[k] = 0
		end
		
		t_u_d[k] = t_u_d[k] + v
	end
end

printLog("av_u:", t/100)
printLog("av_n:", tn/100)
printLog("av_ruri:", tr/100)
printLog("av_heart:", th/100)
printLog("will_get_es:", th/(100*limit_score_h)*21)

printLog("av_u_d:")
for k,v in pairs(t_u_d) do
	printLog(k, v/100)
end

