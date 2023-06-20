
function string.split(s, sep, limit, plain)
	check("s,?s,?n,?b")

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
	if not scheck("u:xml-node") then return false end

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
	if not scheck("u:xml-node,s") then return false end
	
	for i, child in ipairs(xmlNodeGetChildren(node)) do
		if xmlNodeGetName(child) == name then return child end
	end
	return nil
end