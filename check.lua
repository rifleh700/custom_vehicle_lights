
checkers = {}

local string_match = string.match
local string_format = string.format
local string_gsub = string.gsub
local string_find = string.find
local table_concat = table.concat
local debug_getinfo = debug.getinfo
local debug_getlocal = debug.getlocal

local _string_rep = string.rep
local function string_rep(s, n, sep)
	if n == 1 then return s end
	if n < 1 then return "" end

	return _string_rep(s..(sep or ""), n - 1)..s
end

local function mta_type(value)

	local t = type(value)
	if t ~= "userdata" then return t end

	local udt = getUserdataType(value)
	if udt == t then return t end
	if udt ~= "element" then return t..":"..udt end

	return t..":"..udt..":"..getElementType(value)
end

local function is_subtype(sub, parent)
	
	return
		sub == parent or
		string_find(sub, parent..":", 1, true) == 1
end

local default_checkers = {
	["userdata:element:gui"] = function(v) return string_match(mta_type(v), "^userdata:element:gui%-") end
}

local type_cuts = {
	["b"] = "boolean",
	["n"] = "number",
	["s"] = "string",
	["t"] = "table",
	["u"] = "userdata",
	["f"] = "function",
	["th"] = "thread"
}

local cache = {}

local function parse(pattern)

	if cache[pattern] then return cache[pattern] end

	local result = pattern
	result = string_gsub(result, "(%a+)", type_cuts)
	result = string_gsub(result, "(%?)(%a+)", "nil|%2")
	result = string_gsub(result, "%?", "any")
	result = string_gsub(result, "!", "notnil")
	result = string_gsub(result, "([^,]+)%[(%d)%]", function(t, n) return string_rep(t, tonumber(n), ",") end)

	result = split(result, ",")
	for i = 1, #result do
		result[i] = split(result[i], "|")
	end

	cache[pattern] = result

	return result
end

local function arg_invalid_msg(funcName, argNum, argName, msg)

	msg = msg and string_format(" (%s)", msg) or ""

	return string_format(
		"bad argument #%d '%s' to '%s'%s",
		argNum, argName or "?", funcName or "?", msg
	)
end

local function expected_msg(variants, found)

	local expected = {}
	for i = 1, #variants do
		expected[i] = string_gsub(variants[i], ".+:", "")
	end
	expected = table_concat(expected, "\\")
	found = string_gsub(found, ".+:", "")

	return string_format(
		"%s expected, got %s",
		expected, found
	)
end

function warn(msg, lvl)
	check("s,?n")

	lvl = (lvl or 1) + 1
	local dbInfo = debug_getinfo(lvl, "lS")

	if dbInfo and lvl > 1 then
		local src = dbInfo.short_src
		local line = dbInfo.currentline

		msg = string_format(
			"%s:%s: %s",
			src, line, msg
		)
	end

	return outputDebugString("WARNING: "..msg, 4, 255, 127, 0)
end

local function check_one(variants, value)

	local valueType = mta_type(value)
	local mt = getmetatable(value)
	local valueClass = mt and mt.__type
	
	for i = 1, #variants do

		local variant = variants[i]

		if variant == "any" then return true end
		if variant == "notnil" and value ~= nil then return true end
		if valueClass and valueClass == variant then return true end

		if is_subtype(valueType, variant) then return true end

		local checker = default_checkers[variant]
		if checker and checker(value) then return true end

		checker = checkers[variant]
		if type(checker) == "function" and checker(value) then return true end
	end

	local msg = expected_msg(variants, valueClass or valueType)
	return false, msg
end

local function check_main(pattern)

	local parsed = parse(pattern)
	for argNum = 1, #parsed do

		local argName, value = debug_getlocal(3, argNum)
		local success, descMsg = check_one(parsed[argNum], value)
		if not success then

			local funcName = debug_getinfo(3, "n").name
			local msg = arg_invalid_msg(funcName, argNum, argName, descMsg)
			return false, msg
		end
	end

	return true
end

function check(pattern)
	if type(pattern) ~= "string" then check("string") end

	local success, msg = check_main(pattern)
	if not success then error(msg, 3) end

	return true
end

function scheck(pattern)
	if type(pattern) ~= "string" then check("string") end

	local success, msg = check_main(pattern)
	if not success then return warn(msg, 3) and false end

	return true
end
