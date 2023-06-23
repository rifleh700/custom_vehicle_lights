
local resources = {}

local function onStart(resource)
	resources[getResourceName(resource)] = resource
end
addEventHandler("onResourceStart", root, onStart)
addEventHandler("onClientResourceStart", root, onStart)

local function onStop(resource)
	resources[getResourceName(resource)] = nil
end
addEventHandler("onResourceStop", root, onStop)
addEventHandler("onClientResourceStop", root, onStop)

function import(resourceName, defineSpace, spaceName)
	if type(resourceName) ~= "string" then error("bad argument #1 to 'import' (string expected)", 2) end
	if defineSpace and defineSpace ~= true then error("bad argument #2 to 'import' (boolean expected)", 2) end
	if spaceName and type(spaceName) ~= "string" then error("bad argument #3 to 'import' (string expected)", 2) end

	local importResource = getResourceFromName(resourceName)
	if not importResource then error("resource '"..resourceName.."' not found", 2) end
	if getResourceState(importResource) ~= "running" then error("resource '"..resourceName.."' is not running", 2) end
	if importResource == getThisResource() then error("can't import from same resource", 2) end

	resources[resourceName] = importResource

	spaceName = defineSpace and (spaceName or resourceName)

	local space = _G
	if spaceName then
		space = {}
		_G[spaceName] = space
	end

	for _, functionName in ipairs(getResourceExportedFunctions(importResource)) do
		space[functionName] = function(...)
			local thisResource = resources[resourceName]
			if not thisResource then error("resource '"..resourceName.."' is not running", 2) end
			return call(thisResource, functionName, ...)
		end
	end

	return true
end

import("extended_custom_coronas")