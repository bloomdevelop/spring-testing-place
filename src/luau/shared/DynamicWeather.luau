--!strict
-- WeatherSystem Module (Typed)

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

export type WeatherProfile = {
	Cover: number,
	Density: number,
	Color: Color3,
}

export type WeatherType = "Clear" | "Partly" | "Overcast" | "Storm"

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

-- Auto cycle
local cycleTime: number = 120
local timer: number = 0

local weatherOrder: {WeatherType} = {"Clear","Partly","Overcast","Storm"}
local weatherIndex: number = 1

local function cycleWeather(dt: number)
	timer += dt
	if timer >= cycleTime then
		timer = 0
		weatherIndex = weatherIndex % #weatherOrder + 1
		WeatherSystem:SetWeather(weatherOrder[weatherIndex])
	end
end

-- Update loop
RunService.Heartbeat:Connect(function(dt: number)
	cycleWeather(dt)

	cumulus.Cover = lerp(cumulus.Cover, target.Cover, smoothing)
	cumulus.Density = lerp(cumulus.Density, target.Density, smoothing)
	cumulus.Color = lerpColor(cumulus.Color, target.Color, smoothing)
end)

return WeatherSystem
