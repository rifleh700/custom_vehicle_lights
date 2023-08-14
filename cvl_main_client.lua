
local CONFIG_PATH = "cvl_config.xml"
local SHADER_PATH = "lights.fx"

--Vehicle streaming out distance is 300
local SHADER_MAX_DISTANCE = 350

local CORONA_OUTER_CONE = 180
local CORONA_INNER_CONE = 90

local vehicleModelDefaultDummiesNames = {
	["headlights"] = "light_front_main",
	["headlights2"] = "light_front_second",
	["taillights"] = "light_rear_main",
	["taillights2"] = "light_rear_second"
}

local vehicleModelDefaultDummiesRotation = {
	["headlights"] = {0, 0, 0},
	["headlights2"] = {0, 0, 0},
	["taillights"] = {0, 0, 180},
	["taillights2"] = {0, 0, 180},
}

CVL = {}
CVL.globalData = {}
CVL.modelsData = {}
CVL.vehiclesData = {}

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

function CVL.buildShaderLightsPowerContainer(vehicle)

	local lightsPower = (CVL.vehiclesData[vehicle] or {}).power or {}
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

function CVL.applyShader(vehicle)

	local vehicleData = CVL.vehiclesData[vehicle]
	if not vehicleData then
		vehicleData = {}
		CVL.vehiclesData[vehicle] = vehicleData
	end

	if vehicleData.shader then return false end

	local shader = dxCreateShader(SHADER_PATH, CVL.globalData.macros, 0, SHADER_MAX_DISTANCE, false, "vehicle")
	dxSetShaderValue(shader, "sDataContainer1", CVL.buildShaderLightsPowerContainer(vehicle))

	for i, textureName in ipairs(CVL.globalData.textures) do
		engineApplyShaderToWorldTexture(shader, textureName, vehicle, false)
	end
	vehicleData.shader = shader

	return true
end

function CVL.removeShader(vehicle)

	local vehicleData = CVL.vehiclesData[vehicle]
	if not vehicleData then return false end

	local shader = vehicleData.shader
	if not shader then return false end

	if isElement(shader) then
		destroyElement(shader)
	end
	vehicleData.shader = nil

	return true
end

function CVL.createCoronas(vehicle)

	local vehicleData = CVL.vehiclesData[vehicle]
	if not vehicleData then
		vehicleData = {}
		CVL.vehiclesData[vehicle] = vehicleData
	end

	if vehicleData.coronas then return false end

	local vehicleLightsData = vehicleData.lights or {}
	local modelLightsData = (CVL.modelsData[getElementModel(vehicle)] or {}).lights or {}

	local coronas = {}
	for lightID, configLight in ipairs(CVL.globalData.lights) do
		if configLight.dummy then
			local x, y, z = CVL.getDummyPosition(vehicle, configLight.dummy)
			if x then

				local vehicleLight = vehicleLightsData[lightID] or {}
				local modelLight = modelLightsData[lightID] or {}

				local rot = vehicleLight.rot or modelLight.rot
				if not rot then
					rot = {}
					local dx, dy, dz = CVL.getDummyPosition(vehicle, configLight.dummy.."_dir")
					if dx then
						rot[1], rot[2], rot[3] = getRotationFromDirection(dx - x, dy -  y, dz - z)
					else
						rot[1], rot[2], rot[3] = CVL.getDummyRotation(vehicle, configLight.dummy)
					end
				end
				local color = vehicleLight.color or modelLight.color or configLight.color
				local size = vehicleLight.size or modelLight.size or configLight.size

				local corona = createCustomCorona(
					0, 0, 0,
					0, 0, 0,
					"directional",
					 size,
					color[1]*0.5, color[2]*0.5, color[3]*0.5,
					(vehicleLight.power or 0) * color[4])
				setCustomCoronaDepthBias(corona, configLight.size/4)
				setCustomCoronaLightCone(corona, CORONA_OUTER_CONE, CORONA_INNER_CONE)
				attachCustomCorona(corona, vehicle,
					x * (configLight.mirrored and -1 or 1), y, z,
					rot[1], rot[2], rot[3] * (configLight.mirrored and -1 or 1))

				coronas[lightID] = corona
			end
		end
	end

	vehicleData.coronas = coronas

	return true
end

function CVL.removeCoronas(vehicle)

	local vehicleData = CVL.vehiclesData[vehicle]
	if not vehicleData then return false end

	local coronas = vehicleData.coronas
	if not coronas then return false end

	vehicleData.coronas = nil

	for lightID, corona in pairs(coronas) do
		if isElement(corona) then
			destroyElement(corona)
		end
	end

	return true
end

function CVL.loadConfig()
	
	local configNode = xmlLoadFile(CONFIG_PATH, true)
	local texturesConfigNode = xmlNodeFindChild(configNode, "textures")
	local texturesConfigNodeData = xmlNodeGetData(texturesConfigNode)
	local lightsConfigNode = xmlNodeFindChild(configNode, "lights")
	local lightsConfigNodeData = xmlNodeGetData(lightsConfigNode)
	local modelsConfigNode = xmlNodeFindChild(configNode, "models")
	local modelsConfigNodeData = xmlNodeGetData(modelsConfigNode)
	xmlUnloadFile(configNode)

	local textures = {}
	for i, nodeData in ipairs(texturesConfigNodeData.children) do
		table.insert(textures, nodeData.attributes.name)
	end

	local macroFlagsArray = ""
	local globalLights = {}
	local ids = {}
	for i, nodeData in ipairs(lightsConfigNodeData.children) do
		local lightData = {
			name = nodeData.attributes.name,
			dummy = nodeData.attributes.dummy
		}
		if lightData.dummy then
			lightData.mirrored = nodeData.attributes.mirrored == tostring(true)
			lightData.size = tonumber(nodeData.attributes.size)
			lightData.color = {}
			local iterator = string.gmatch(nodeData.attributes.color, "%d+")
			for c = 1, 4 do
				lightData.color[c] = tonumber(iterator() or 255)
			end
		end
		globalLights[i] = lightData
		ids[lightData.name] = i

		local flag = {}
		local iterator = string.gmatch(nodeData.attributes.flag, "%d+")
		for c = 1, 3 do
			flag[c] = iterator() or 0
		end
		macroFlagsArray = macroFlagsArray..string.format("float3(%s),", table.concat(flag, ","))
	end

	local modelsData = {}
	for i, modelNodeData in ipairs(modelsConfigNodeData.children) do
		local modelLights = {}
		for j, lightNodeData in ipairs(modelNodeData.children) do
			local lightData = {}
			if lightNodeData.attributes.color then
				lightData.color = {}
				local iterator = string.gmatch(lightNodeData.attributes.color, "%d+")
				for c = 1, 4 do
					lightData.color[c] = tonumber(iterator() or 255)
				end
			end
			if lightNodeData.attributes.size then
				lightData.size = tonumber(lightNodeData.attributes.size)
			end
			if lightNodeData.attributes.rotation then
				lightData.rot = {}
				local iterator = string.gmatch(lightNodeData.attributes.rotation, "%d+")
				for c = 1, 3 do
					lightData.rot[c] = tonumber(iterator() or 0)
				end
			end
			modelLights[ids[lightNodeData.attributes.name]] = lightData
		end
		modelsData[tonumber(modelNodeData.attributes.id)] = {
			lights = modelLights
		}
	end

	CVL.globalData = {
		textures = textures,
		lights = globalLights,
		ids = ids,
		macros = {
			MACRO_LIGHTS_FLAGS_ARRAY_SIZE = #globalLights,
			MACRO_LIGHTS_FLAGS_ARRAY = macroFlagsArray
		}
	}

	CVL.modelsData = modelsData

	return true
end

function CVL.updateAll()

	for vehicle, data in pairs(CVL.vehiclesData) do
		CVL.removeCoronas(vehicle)
		CVL.removeShader(vehicle)
	end
	for i, vehicle in ipairs(getElementsByType("vehicle", root, true)) do
		CVL.applyShader(vehicle)
		CVL.createCoronas(vehicle)
	end
	return true
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()

		CVL.loadConfig()
		CVL.updateAll()
	end
)

addEventHandler("onClientElementStreamIn", root,
	function()
		if getElementType(source) ~= "vehicle" then return end

		CVL.applyShader(source)
		CVL.createCoronas(source)
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

function CVL.setLightPower(vehicle, lightID, power)

	local vehicleData = CVL.vehiclesData[vehicle]
	if not vehicleData then
		vehicleData = {}
		CVL.vehiclesData[vehicle] = vehicleData
	end

	local lightsPower = vehicleData.power
	if not lightsPower then
		lightsPower = {}
		vehicleData.power = lightsPower
	end

	lightsPower[lightID] = power

	local shader = vehicleData.shader
	if shader then
		local shaderLightsPower = CVL.buildShaderLightsPowerContainer(vehicle)
		dxSetShaderValue(shader, "sDataContainer1", shaderLightsPower)
	end

	local corona = (vehicleData.coronas or {})[lightID]
	if corona then
		local alpha = power * CVL.globalData.lights[lightID].color[4]
		setCustomCoronaAlpha(corona, alpha)
	end

	return true
end

function CVL.setLightSize(vehicle, lightID, size)

	local vehicleData = CVL.vehiclesData[vehicle]
	if not vehicleData then
		vehicleData = {}
		CVL.vehiclesData[vehicle] = vehicleData
	end

	local lightsData = vehicleData.lights
	if not lightsData then
		lightsData = {}
		vehicleData.lights = lightsData
	end

	local lightData = lightsData[lightID]
	if not lightData then
		lightData = {}
		lightsData[lightID] = lightData
	end

	lightData.size = size

	local corona = (vehicleData.coronas or {})[lightID]
	if corona then
		local modelSize = (((CVL.modelsData[getElementModel(vehicle)] or {}).lights or {})[lightID] or {}).size
		setCustomCoronaSize(corona,
			size or modelSize or CVL.globalData.lights[lightID].size)
	end

	return true
end

function CVL.setLightColor(vehicle, lightID, color)

	local vehicleData = CVL.vehiclesData[vehicle]
	if not vehicleData then
		vehicleData = {}
		CVL.vehiclesData[vehicle] = vehicleData
	end

	local lightsData = vehicleData.lights
	if not lightsData then
		lightsData = {}
		vehicleData.lights = lightsData
	end

	local lightData = lightsData[lightID]
	if not lightData then
		lightData = {}
		lightsData[lightID] = lightData
	end

	lightData.color = color

	local corona = (vehicleData.coronas or {})[lightID]
	if corona then
		local modelColor = (((CVL.modelsData[getElementModel(vehicle)] or {}).lights or {})[lightID] or {}).color
		color = color or modelColor or CVL.lightsData[lightID].color
		setCustomCoronaColor(corona,
			color[1] * 0.5,
			color[2] * 0.5,
			color[3] * 0.5,
			((vehicleData.power or {})[lightID] or 0) * color[4])
	end

	return true
end