
local CONFIG_PATH = "config.xml"
local SHADER_PATH = "lights.fx"
local TEXTURE_NAME = "vehiclelights"
local SHADER_MAX_DISTANCE = 100

local CORONA_OUTER_CONE = 180
local CORONA_INNER_CONE = 60

local vehicleModelDefaultDummiesNames = {
	["headlights"] = "light_front_main",
	["headlights2"] = "light_front_second",
	["taillights"] = "light_rear_main",
	["taillights2"] = "light_rear_second"
}

local vehicleModelDefaultDummiesRotation = {
	["headlights"] = {0, 0, 0},
	["headlights2"] = {0, 0, 0},
	["taillights"] = {0, 180, 0},
	["taillights2"] = {0, 180, 0},
}

CVL = {}
CVL.dummiesData = {}
CVL.lightsData = {}
CVL.shaderMacros = ""
CVL.vehiclesData = {}

function CVL.getData(vehicle, key)
	if not CVL.vehiclesData[vehicle] then return nil end

	return CVL.vehiclesData[vehicle][key]
end

function CVL.setData(vehicle, key, value)
	
	if not CVL.vehiclesData[vehicle] then CVL.vehiclesData[vehicle] = {} end
	CVL.vehiclesData[vehicle][key] = value

	return true
end

function CVL.toShaderLightsPower(lightsPower)
	
	local shaderLightsPower = {}
	for i = 1, 16 do
		local packed = 0
		for p = 1, 3 do
			packed = packed + math.floor((lightsPower[(i-1)*3+p] or 0)*255) * 256^(p-1)
		end
		shaderLightsPower[i] = packed
	end

	return shaderLightsPower
end

function CVL.getDummyPosition(vehicle, dummy)
	
	local defaultDummy = vehicleModelDefaultDummiesNames[dummy]
	if defaultDummy then
		return getVehicleModelDummyPosition(getElementModel(vehicle), defaultDummy)
	end

	return getVehicleComponentPosition(vehicle, dummy)
end

function CVL.getDummyRotation(vehicle, dummy)
	
	local defaultDummy = vehicleModelDefaultDummiesNames[dummy]
	if defaultDummy then
		return unpack(vehicleModelDefaultDummiesRotation[dummy])
	end

	return getVehicleComponentRotation(vehicle, dummy, "root")
end

function CVL.setLightPower(vehicle, lightID, power)

	local lightsPower = CVL.getData(vehicle, "power") or {}
	lightsPower[lightID] = power
	CVL.setData(vehicle, "power", lightsPower)

	local shader = CVL.getData(vehicle, "shader")
	if shader then
		local shaderLightsPower = CVL.toShaderLightsPower(lightsPower)
		dxSetShaderValue(shader, "sDataContainer1", shaderLightsPower)
	end

	local corona = (CVL.getData(vehicle, "coronas") or {})[lightID]
	if corona then
		local alpha = power * CVL.dummiesData[CVL.lightsData[lightID].dummy].color[4]
		setCoronaAlpha(corona, alpha)
	end

	return true
end

function CVL.createCoronas(vehicle)
	if CVL.getData(vehicle, "coronas") then return false end

	local coronas = {}
	for lightID, lightData in ipairs(CVL.lightsData) do
		if lightData.dummy then
			local dummyData = CVL.dummiesData[lightData.dummy]
			if dummyData then
				local offX, offY, offZ = CVL.getDummyPosition(vehicle, lightData.dummy)
				if offX then
					local alpha = (lightData.power or 0) * dummyData.color[4]
					local corona = createDirectionalCorona(0, 0, 0, 0, 0, 0, dummyData.size, dummyData.color[1], dummyData.color[2], dummyData.color[3], alpha)
					setDirectionalCoronaCone(corona, CORONA_OUTER_CONE, CORONA_INNER_CONE)
					local offRX, offRY, offRZ = CVL.getDummyRotation(vehicle, lightData.dummy)
					local isLeft = lightData.side == "left"
					attachCorona(corona, vehicle, offX * (isLeft and -1 or 1), offY, offZ, offRX, offRZ, -offRY * (isLeft and -1 or 1))
					coronas[lightID] = corona
				end
			end
		end
	end
	CVL.setData(vehicle, "coronas", coronas)

	return true
end

function CVL.applyShader(vehicle)
	if CVL.getData(vehicle, "shader") then return false end

	local shader = dxCreateShader(SHADER_PATH, CVL.shaderMacros, 0, SHADER_MAX_DISTANCE, false, "vehicle")
	dxSetShaderValue(shader, "sDataContainer1", CVL.toShaderLightsPower(CVL.getData(vehicle, "power") or {}))
 
	engineApplyShaderToWorldTexture(shader, TEXTURE_NAME, vehicle, false)
	CVL.setData(vehicle, "shader", shader)

	return true
end

function CVL.removeCoronas(vehicle)
	
	local coronas = CVL.getData(vehicle, "coronas")
	if not coronas then return false end

	CVL.setData(vehicle, "coronas", nil)
	for lightID, corona in pairs(coronas) do
		destroyElement(corona)
	end

	return true
end

function CVL.removeShader(vehicle)
	
	local shader = CVL.getData(vehicle, "shader")
	if not shader then return false end

	CVL.setData(vehicle, "shader", nil)
	if isElement(shader) then
		destroyElement(shader)
	end

	return true
end

addEventHandler("onClientElementStreamIn", root,
	function()
		if getElementType(source) ~= "vehicle" then return end

		CVL.createCoronas(source)
		CVL.applyShader(source)
	end
)

addEventHandler("onClientElementStreamOut", root,
	function()
		if getElementType(source) ~= "vehicle" then return end

		CVL.removeCoronas(source)
		CVL.removeShader(source)
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
		if not CVL.vehiclesData[source] then return end

		CVL.removeCoronas(source)
		CVL.removeShader(source)
		CVL.vehiclesData[source] = nil
	end
)

function CVL.loadConfig()
		
	local testNode = xmlLoadFile("meta.xml", true)
	local v = xmlNodeGetData(testNode)
	iprint(v)

	local configNode = xmlLoadFile(CONFIG_PATH, true)
	local dummiesConfigNode = xmlNodeFindChild(configNode, "dummies")
	local dummiesConfigNodeData = xmlNodeGetData(dummiesConfigNode)
	local lightsConfigNode = xmlNodeFindChild(configNode, "lights")
	local lightsConfigNodeData = xmlNodeGetData(lightsConfigNode)
	xmlUnloadFile(configNode)

	local dummiesData = {}
	for i, nodeData in ipairs(dummiesConfigNodeData.children) do
		local dummyData = {
			size = tonumber(nodeData.attributes.size),
			color = {}
		}
		local iterator = string.gmatch(nodeData.attributes.color, "%d+")
		for c = 1, 4 do
			dummyData.color[c] = tonumber(iterator() or 255)
		end
		dummiesData[nodeData.attributes.name] = dummyData
	end
	CVL.dummiesData = dummiesData

	local macroFlagsArray = ""
	local lightsData = {}
	for i, nodeData in ipairs(lightsConfigNodeData.children) do
		local lightData = {
			name = nodeData.attributes.name,
			dummy = nodeData.attributes.dummy,
			side = nodeData.attributes.side
		}
		lightsData[i] = lightData

		local flag = {}
		local iterator = string.gmatch(nodeData.attributes.flag, "%d+")
		for c = 1, 3 do
			flag[c] = iterator() or 0
		end
		macroFlagsArray = macroFlagsArray..string.format("float3(%s),", table.concat(flag, ","))
	end
	CVL.lightsData = lightsData

	CVL.shaderMacros = {
		MACRO_LIGHTS_FLAGS_ARRAY_SIZE = #lightsData,
		MACRO_LIGHTS_FLAGS_ARRAY = macroFlagsArray
	}

	return true
end

function CVL.init()

	CVL.loadConfig()

	for i, vehicle in ipairs(getElementsByType("vehicle", root, true)) do
		CVL.setData(vehicle, "power", lightsPower)
		CVL.applyShader(vehicle)
		CVL.createCoronas(vehicle)
	end

	return true
end

addEventHandler("onClientResourceStart", resourceRoot, CVL.init)