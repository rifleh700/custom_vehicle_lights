
function warn(msg, lvl)
	if type(msg) ~= "string" then error("bad argument #1 'msg' to 'warn' (string expected)", 3) end
	if lvl and type(lvl) ~= "number" then error("bad argument #2 'lvl' to 'warn' (number expected)", 3) end

	lvl = (lvl or 1) + 1
	local dbInfo = debug.getinfo(lvl, "lS")

	if dbInfo and lvl > 1 then
		local src = dbInfo.short_src
		local line = dbInfo.currentline

		msg = string.format(
			"%s:%s: %s",
			src, line, msg
		)
	end

	return outputDebugString("WARNING: "..msg, 4, 255, 127, 0)
end

function math.clamp(value, min, max)

	return value < min and min or value > max and max or value
end

function string.split(s, sep, limit, plain)

	if limit and limit < 1 then return {} end
	if s == "" then return {""} end

	sep = sep or ""
	sep = plain and string.literalize(sep) or sep

	local t = {}
	local iter = string.gmatch(s, sep == "" and "." or "([^"..sep.."]+)")
	for v in iter do
        t[#t + 1] = v
        if limit and #t == limit then break end
    end

	return t
end

function xmlNodeGetData(node)

	local data = {}
	data.name = xmlNodeGetName(node)
	data.value = xmlNodeGetValue(node)
	data.attributes = xmlNodeGetAttributes(node)
	data.children = {}

	local children = xmlNodeGetChildren(node)
	if #children == 0 then return data end

	for i, childNode in ipairs(children) do
		data.children[i] = xmlNodeGetData(childNode)
	end

	return data
end

function xmlNodeFindChild(node, name)

	for i, child in ipairs(xmlNodeGetChildren(node)) do
		if xmlNodeGetName(child) == name then return child end
	end
	return nil
end

function getRotationFromDirection(dirX, dirY, dirZ)

	return
		math.deg(math.atan2(dirZ, getDistanceBetweenPoints2D(dirX, dirY, 0, 0))),
		0,
		-math.deg(math.atan2(dirX, dirY))
end