
function getVehicleCustomLightPower(vehicle, name)
	if not(type(vehicle) == "userdata" and isElement(vehicle) and getElementType(vehicle) == "vehicle") then
		error("bad argument #1 'vehicle' to 'getVehicleCustomLightPower' (vehicle expected)", 2) end
	if type(name) ~= "string" then error("bad argument #2 'name' to 'getVehicleCustomLightPower' (string expected)", 2) end

	local lightID = CVL.globalData.ids[name]
	if not lightID then return warn("bad argument #2 'name' to 'getVehicleCustomLightPower' (illegal light name '".. name .."')", 2) and false end

	return ((CVL.vehiclesData[vehicle] or {}).power or {})[lightID] or 0
end

function setVehicleCustomLightPower(vehicle, name, power)
	if not(type(vehicle) == "userdata" and isElement(vehicle) and getElementType(vehicle) == "vehicle") then
		error("bad argument #1 'vehicle' to 'setVehicleCustomLightPower' (vehicle expected)", 2) end
	if type(name) ~= "string" then error("bad argument #2 'name' to 'setVehicleCustomLightPower' (string expected)", 2) end
	if type(power) ~= "number" then error("bad argument #3 'power' to 'setVehicleCustomLightPower' (number expected)", 2) end

	local lightID = CVL.globalData.ids[name]
	if not lightID then return warn("bad argument #2 'name' to 'setVehicleCustomLightPower' (illegal light name '".. name .."')", 2) and false end

	return CVL.setLightPower(vehicle, lightID, math.clamp(power, 0, 1))
end

function getVehicleCustomLightSize(vehicle, name)
	if not(type(vehicle) == "userdata" and isElement(vehicle) and getElementType(vehicle) == "vehicle") then
		error("bad argument #1 'vehicle' to 'getVehicleCustomLightSize' (vehicle expected)", 2) end
	if type(name) ~= "string" then error("bad argument #2 'name' to 'getVehicleCustomLightSize' (string expected)", 2) end

	local lightID = CVL.globalData.ids[name]
	if not lightID then return warn("bad argument #2 'name' to 'getVehicleCustomLightSize' (illegal light name '".. name .."')", 2) and false end

	return (((CVL.vehiclesData[vehicle] or {}).lights or {})[lightID] or {}).size or CVL.globalData.lights[lightID].size
end

function setVehicleCustomLightSize(vehicle, name, size)
	if not(type(vehicle) == "userdata" and isElement(vehicle) and getElementType(vehicle) == "vehicle") then
		error("bad argument #1 'vehicle' to 'setVehicleCustomLightSize' (vehicle expected)", 2) end
	if type(name) ~= "string" then error("bad argument #2 'name' to 'setVehicleCustomLightSize' (string expected)", 2) end
	if size and type(size) ~= "number" then error("bad argument #3 'size' to 'setVehicleCustomLightSize' (number expected)", 2) end

	local lightID = CVL.globalData.ids[name]
	if not lightID then return warn("bad argument #2 'name' to 'setVehicleCustomLightSize' (illegal light name '".. name .."')", 2) and false end

	return CVL.setLightSize(vehicle, lightID, size and math.max(0, size) or nil)
end

function getVehicleCustomLightColor(vehicle, name)
	if not(type(vehicle) == "userdata" and isElement(vehicle) and getElementType(vehicle) == "vehicle") then
		error("bad argument #1 'vehicle' to 'getVehicleCustomLightColor' (vehicle expected)", 2) end
	if type(name) ~= "string" then error("bad argument #2 'name' to 'getVehicleCustomLightColor' (string expected)", 2) end

	local lightID = CVL.globalData.ids[name]
	if not lightID then return warn("bad argument #2 'name' to 'getVehicleCustomLightColor' (illegal light name '".. name .."')", 2) and false end

	local color = (((CVL.vehiclesData[vehicle] or {}).lights or {})[lightID] or {}).color or CVL.globalData.lights[lightID].color

	return color[1], color[2], color[3], color[4]
end

function setVehicleCustomLightColor(vehicle, name, r, g, b, a)
	if not(type(vehicle) == "userdata" and isElement(vehicle) and getElementType(vehicle) == "vehicle") then
		error("bad argument #1 'vehicle' to 'setVehicleCustomLightColor' (vehicle expected)", 2) end
	if type(name) ~= "string" then error("bad argument #2 'name' to 'setVehicleCustomLightColor' (string expected)", 2) end
	if r and type(r) ~= "number" then error("bad argument #3 'r' to 'setVehicleCustomLightColor' (number expected)", 2) end
	if r and type(g) ~= "number" then error("bad argument #4 'g' to 'setVehicleCustomLightColor' (number expected)", 2) end
	if r and type(b) ~= "number" then error("bad argument #5 'b' to 'setVehicleCustomLightColor' (number expected)", 2) end
	if r and type(a) ~= "number" then error("bad argument #6 'a' to 'setVehicleCustomLightColor' (number expected)", 2) end
	
	local lightID = CVL.globalData.ids[name]
	if not lightID then return warn("bad argument #2 'name' to 'setVehicleCustomLightColor' (illegal light name '".. name .."')", 2) and false end

	return CVL.setLightColor(vehicle, lightID,
		r and g and b and a and
			{math.clamp(math.floor(r), 0, 255),
			 math.clamp(math.floor(g), 0, 255),
			 math.clamp(math.floor(b), 0, 255),
			 math.clamp(math.floor(a), 0, 255)} or nil)
end