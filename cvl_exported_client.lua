

function getVehicleCustomLightName(lightID)
	if not scheck("n") then return false end

	lightID = math.floor(lightID)
	local data = CVL.lightsData[lightID]
	if not data then return false end

	return data.name
end

function getVehicleCustomLightFromName(name)
	if not scheck("s") then return false end

	for lightID, data in ipairs(CVL.lightsData) do
		if data.name == name then return lightID end
	end
	return nil
end

function getVehicleCustomLightPower(vehicle, lightID)
	if not scheck("u:element:vehicle,n") then return false end

	lightID = math.floor(lightID)
	if not CVL.lightsData[lightID] then return false end

	local lightsPower = CVL.getData(vehicle, "power") or {}
	return lightsPower[lightID] or 0
end

function setVehicleCustomLightPower(vehicle, lightID, power)
	if not scheck("u:element:vehicle,n,n") then return false end
	
	lightID = math.floor(lightID)
	if not CVL.lightsData[lightID] then return false end
	
	power = math.min(1, math.max(0, power))

	return CVL.setLightPower(vehicle, lightID, power)
end