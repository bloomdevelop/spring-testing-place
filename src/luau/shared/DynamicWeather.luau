--!strict
-- WeatherSystem Module (Typed)

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

export type WeatherProfile = {
	Cover: number,
	Density: number,
	Color: Color3,
}

export type WeatherType = "Clear" | "Partly" | "Overcast" | "Storm" | "Foggy" | "Rainy" | "Snowy" | "Windy" | "Drizzle" | "Thunderstorm" | "Sunny" | "Hazy"

export type WeatherSystem = {
	SetWeather: (self: WeatherSystem, type: WeatherType) -> (),
    GetWeather: (self: WeatherSystem) -> ()
}

local WeatherSystem: WeatherSystem = {} :: WeatherSystem

-- Ensure Clouds
local cumulus = Lighting:FindFirstChildOfClass("Clouds")
if not cumulus then
	cumulus = Instance.new("Clouds")
	cumulus.Cover = 0.2
	cumulus.Density = 0.5
	cumulus.Parent = workspace.Terrain
end

-- State
local currentWeather: WeatherType = "Clear"
local target: WeatherProfile = {Cover = 0.2, Density = 0.3, Color = Color3.new(1,1,1)}
local smoothing: number = 0.02

-- Profiles
local profiles: {[WeatherType]: WeatherProfile} = {
	Clear =  {Cover = 0.05, Density = 0.2, Color = Color3.new(1,1,1)},
	Partly = {Cover = 0.4, Density = 0.6, Color = Color3.fromRGB(220,220,230)},
	Overcast = {Cover = 0.8, Density = 0.9, Color = Color3.fromRGB(200,200,210)},
	Storm = {Cover = 1.0, Density = 1.0, Color = Color3.fromRGB(160,170,180)},
	Foggy = {Cover = 0.9, Density = 1.0, Color = Color3.fromRGB(240,240,250)},  -- Thick fog
	Rainy = {Cover = 0.9, Density = 0.8, Color = Color3.fromRGB(180,190,200)},  -- Rain clouds
	Snowy = {Cover = 0.7, Density = 0.9, Color = Color3.fromRGB(250,250,255)},  -- Snowy white
	Windy = {Cover = 0.3, Density = 0.4, Color = Color3.fromRGB(210,220,240)},  -- Light clouds, windy
	Drizzle = {Cover = 0.6, Density = 0.7, Color = Color3.fromRGB(190,200,210)},  -- Light rain
	Thunderstorm = {Cover = 1.0, Density = 1.0, Color = Color3.fromRGB(140,150,160)},  -- Dark storm
	Sunny = {Cover = 0.0, Density = 0.1, Color = Color3.new(1,1,1)},  -- No clouds
	Hazy = {Cover = 0.5, Density = 0.6, Color = Color3.fromRGB(230,230,240)},  -- Light haze
}

-- Utility
local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function lerpColor(a: Color3, b: Color3, t: number): Color3
	return Color3.new(
		lerp(a.R, b.R, t),
		lerp(a.G, b.G, t),
		lerp(a.B, b.B, t)
	)
end

-- Altitude-based adjustments
-- Define altitude ranges and their effects on weather
local ALTITUDE_LOW = 0 -- Sea level
local ALTITUDE_MAX = 2000 -- Maximum altitude for full effect

-- Function to get altitude-based modifiers
local function getAltitudeModifiers(altitude: number): {Cover: number, Density: number, Color: Color3}
	-- Normalize altitude between 0 and 1 for interpolation
	local normalizedAlt = math.clamp((altitude - ALTITUDE_LOW) / (ALTITUDE_MAX - ALTITUDE_LOW), 0, 1)

	-- At higher altitudes: reduce cloud cover and density, make sky bluer (less atmospheric scattering)
	local coverModifier = 1 - (normalizedAlt * 0.3) -- Reduce cover by up to 30%
	local densityModifier = 1 - (normalizedAlt * 0.4) -- Reduce density by up to 40%
	local colorModifier = Color3.new(
		lerp(1, 0.8, normalizedAlt), -- Slightly less red
		lerp(1, 0.9, normalizedAlt), -- Slightly less green
		lerp(1, 1.1, normalizedAlt)  -- More blue for clearer sky
	)

	return {
		Cover = coverModifier,
		Density = densityModifier,
		Color = colorModifier
	}
end

-- Public API
function WeatherSystem:GetWeather(): WeatherType
	return currentWeather
end


function WeatherSystem:SetWeather(type: WeatherType)
	local profile = profiles[type]
	if profile then
		currentWeather = type
		target = profile
	else
		warn("Unknown weather type: " .. tostring(type))
	end
end

-- Auto cycle with random selection for unpredictability
local cycleTime: number = 120
local timer: number = 0

-- Auto cycle with random selection for unpredictability
local weatherOrder: {WeatherType} = {"Clear","Sunny","Partly","Hazy","Windy","Drizzle","Overcast","Rainy","Foggy","Snowy","Storm","Thunderstorm"}
local weatherIndex: number = 1

local function cycleWeather(dt: number)
	timer += dt
	if timer >= cycleTime then
		timer = 0
		weatherIndex = math.random(1, #weatherOrder)
		WeatherSystem:SetWeather(weatherOrder[weatherIndex])
	end
end

-- Update loop
RunService.Heartbeat:Connect(function(dt: number)
	cycleWeather(dt)

	-- Apply altitude-based adjustments
	local localPlayer = Players.LocalPlayer
	if localPlayer and localPlayer.Character then
		local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			local altitude = humanoidRootPart.Position.Y
			local modifiers = getAltitudeModifiers(altitude)

			-- Adjust target values based on altitude
			target.Cover = target.Cover * modifiers.Cover
			target.Density = target.Density * modifiers.Density
			target.Color = Color3.new(
				target.Color.R * modifiers.Color.R,
				target.Color.G * modifiers.Color.G,
				target.Color.B * modifiers.Color.B
			)
		end
	end

	cumulus.Cover = lerp(cumulus.Cover, target.Cover, smoothing)
	cumulus.Density = lerp(cumulus.Density, target.Density, smoothing)
	cumulus.Color = lerpColor(cumulus.Color, target.Color, smoothing)
end)

return WeatherSystem
