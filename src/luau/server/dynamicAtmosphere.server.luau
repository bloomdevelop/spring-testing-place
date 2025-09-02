local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
	atmosphere = Instance.new("Atmosphere")
	atmosphere.Parent = Lighting
end

local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
if not sunRays then
	sunRays = Instance.new("SunRaysEffect")
	sunRays.Parent = Lighting
end

-- Config
local DAY_LENGTH = 600
local START_HOUR = 5 -- start near sunrise for easier testing
local TURBIDITY = 3.0
local RAYLEIGH_SCALE = 0.8
local MIE_SCALE = 0.7
local OZONE_STRENGTH = 0.5
local EXPOSURE = 2.0
local NIGHT_DENSITY = 0.8
local DAY_DENSITY = 0.12
local NIGHT_BRIGHTNESS = 0.0
local DAY_BRIGHTNESS = 5.0
local SMOOTHING = 6.0 -- larger = faster response


-- Wavelengths (m)
local lambda = { R = 680e-9, G = 550e-9, B = 440e-9 }
local function clamp(x, a, b)
	return math.max(a, math.min(b, x))
end
local function invPow(l, p)
	return 1 / (l ^ p)
end

-- Altitude-based adjustments
local ALTITUDE_LOW = 0 -- Sea level
local ALTITUDE_MAX = 2000 -- Maximum altitude for full effect

-- Function to get average player altitude
local function getAveragePlayerAltitude()
	local totalAltitude = 0
	local playerCount = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				totalAltitude = totalAltitude + humanoidRootPart.Position.Y
				playerCount = playerCount + 1
			end
		end
	end
	return playerCount > 0 and totalAltitude / playerCount or 0
end

-- Function to get altitude-based modifiers for atmosphere
local function getAtmosphereModifiers(altitude: number)
	local normalizedAlt = clamp((altitude - ALTITUDE_LOW) / (ALTITUDE_MAX - ALTITUDE_LOW), 0, 1)

	-- At higher altitudes: reduce density and haze, adjust glare, darken color for space effect
	local densityModifier = 1 - (normalizedAlt * 0.5) -- Reduce density by up to 50%
	local hazeModifier = 1 - (normalizedAlt * 0.3) -- Reduce haze by up to 30%
	local glareModifier = 1 + (normalizedAlt * 0.2) -- Increase glare by up to 20%
	local colorDarkenFactor = 1 - (normalizedAlt * 0.8) -- Darken color by up to 80% towards black

	return {
		Density = densityModifier,
		Haze = hazeModifier,
		Glare = glareModifier,
		ColorDarken = colorDarkenFactor
	}
end

local rayVec = Vector3.new(invPow(lambda.R, 4), invPow(lambda.G, 4), invPow(lambda.B, 4))
local mieVec = Vector3.new(invPow(lambda.R, 1.3), invPow(lambda.G, 1.3), invPow(lambda.B, 1.3))

local function normalizeVec(v)
	local m = math.max(v.X, v.Y, v.Z, 1e-9)
	return Vector3.new(v.X / m, v.Y / m, v.Z / m)
end
rayVec = normalizeVec(rayVec)
mieVec = normalizeVec(mieVec)

local function airMassFromCos(cosZenith)
	local cz = clamp(cosZenith, 0.0001, 1.0)
	local zen = math.deg(math.acos(cz))
	return 1.0 / (cz + 0.15 * (math.pow(93.885 - zen, -1.253)))
end

local function ozoneAbsorptionFactor(wavelength_m, airMass)
	local nm = wavelength_m * 1e9
	local base
	if nm < 500 then
		base = 0.45
	elseif nm < 650 then
		base = 0.12
	else
		base = 0.02
	end
	return math.exp(-base * OZONE_STRENGTH * airMass)
end

local function tonemap(vec, exposure)
	local x = 1 - math.exp(-vec.X * exposure)
	local y = 1 - math.exp(-vec.Y * exposure)
	local z = 1 - math.exp(-vec.Z * exposure)
	local gamma = 1 / 2.2
	return Vector3.new(x ^ gamma, y ^ gamma, z ^ gamma)
end

local function lerp(a, b, t)
	return a + (b - a) * clamp(t, 0, 1)
end

local startTick = tick()
local startOffset = (START_HOUR % 24) / 24

-- keep last applied color for smoothing
local lastColor = Vector3.new(0.005, 0.01, 0.02)

local function updateAtmosphere()
	local elapsed = tick() - startTick
	local cycle = ((elapsed / DAY_LENGTH) + startOffset) % 1
	Lighting.ClockTime = cycle * 24

	local sunDir = Lighting:GetSunDirection() or Vector3.new(0, -1, 0)

	-- CORRECTED: cosZenith is dot(sunDir, up) -> sunDir.Y is positive above horizon
	local cosZenith = clamp(sunDir.Y, -1, 1)
	local aboveHorizon = cosZenith > 0

	local am = aboveHorizon and airMassFromCos(cosZenith) or 10.0

	-- attenuation
	local rayAttR = math.exp(-rayVec.X * RAYLEIGH_SCALE * am)
	local rayAttG = math.exp(-rayVec.Y * RAYLEIGH_SCALE * am)
	local rayAttB = math.exp(-rayVec.Z * RAYLEIGH_SCALE * am)

	local mieAttR = math.exp(-mieVec.X * MIE_SCALE * TURBIDITY * am)
	local mieAttG = math.exp(-mieVec.Y * MIE_SCALE * TURBIDITY * am)
	local mieAttB = math.exp(-mieVec.Z * MIE_SCALE * TURBIDITY * am)

	local scatR = (1 - rayAttR) * 1.0 + (1 - mieAttR) * 0.3
	local scatG = (1 - rayAttG) * 1.0 + (1 - mieAttG) * 0.3
	local scatB = (1 - rayAttB) * 1.0 + (1 - mieAttB) * 0.3

	local oR = ozoneAbsorptionFactor(lambda.R, am)
	local oG = ozoneAbsorptionFactor(lambda.G, am)
	local oB = ozoneAbsorptionFactor(lambda.B, am)

	local combinedR = scatR * oR
	local combinedG = scatG * oG
	local combinedB = scatB * oB

	local dayWeight = clamp(cosZenith, 0, 1)
	local sunsetBoost = (1 - math.abs(cosZenith))

	local colorVec = Vector3.new(
		combinedR * (0.6 * dayWeight + 1.5 * sunsetBoost),  -- Increased red for Earth-like sunset
		combinedG * (0.8 * dayWeight + 0.9 * sunsetBoost),  -- Moderate green boost
		combinedB * (1.0 * dayWeight + 0.05 * sunsetBoost)  -- Reduced blue for warmer sunset
	)

	local mapped = tonemap(colorVec * EXPOSURE, EXPOSURE)
	if not aboveHorizon then
		mapped = Vector3.new(0.005, 0.01, 0.02)
	end

	local maxC = math.max(mapped.X, mapped.Y, mapped.Z, 1e-6)
	local normalized = Vector3.new(mapped.X / maxC, mapped.Y / maxC, mapped.Z / maxC)
		* lerp(0.25, 1.0, clamp(cosZenith, 0, 1))

	-- smoothing
	local dt = math.clamp(1 / 60, 0, 1)
	local t = 1 - math.exp(-SMOOTHING * dt) -- frame-rate independent lerp factor
	lastColor = lastColor:Lerp(normalized, t)

	-- Apply altitude-based adjustments
	local averageAltitude = getAveragePlayerAltitude()
	local modifiers = getAtmosphereModifiers(averageAltitude)

	atmosphere.Color = Color3.new(lastColor.X, lastColor.Y, lastColor.Z):Lerp(Color3.new(0, 0, 0), 1 - modifiers.ColorDarken)

	atmosphere.Decay = Color3.fromRGB(180, 200, 220):Lerp(Color3.fromRGB(255, 150, 50), clamp(1 - cosZenith, 0, 1))  -- Orange sunset decay

	atmosphere.Density = lerp(NIGHT_DENSITY, DAY_DENSITY, clamp(cosZenith, 0, 1)) * modifiers.Density
	atmosphere.Haze = (0.8 + (1 - math.abs(cosZenith)) * 3.2 * TURBIDITY) * modifiers.Haze
	atmosphere.Glare = clamp((cosZenith > 0 and math.pow(cosZenith, 0.6) or 0) * 0.6, 0, 3) * modifiers.Glare

	Lighting.Brightness = lerp(NIGHT_BRIGHTNESS, DAY_BRIGHTNESS, math.pow(clamp(cosZenith, 0, 1), 0.7))
	Lighting.OutdoorAmbient = atmosphere.Color:lerp(Color3.fromRGB(20, 20, 40), 0.45)

	-- DEBUG: uncomment to see values in Output while testing
	-- print("sunDir.Y", sunDir.Y, "cosZenith", cosZenith, "aboveHorizon", aboveHorizon)

	local sunRayIntensity = (clamp(cosZenith, 0, 1) ^ 0.6) * 0.7
	local sunRaySpread = (clamp(cosZenith, 0, 1) ^ 0.4) * 0.8

	sunRays.Intensity = sunRayIntensity
	sunRays.Spread = sunRaySpread
end

-- initial update and loop
updateAtmosphere()
print("Dynamic Atmosphere successfully initalized!")
RunService.Heartbeat:Connect(updateAtmosphere)
