local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Settings
local DAY_LENGTH_SECONDS = 600
local NIGHT_COLOR = Color3.fromRGB(8, 8, 14)
local DAY_COLOR = Color3.fromRGB(255, 255, 255)
local SUNRISE_COLOR = Color3.fromRGB(255, 150, 64)
local SUNSET_COLOR = Color3.fromRGB(255, 105, 59)

local function lerpColor(c1, c2, t)
	return Color3.new(c1.R + (c2.R - c1.R) * t, c1.G + (c2.G - c1.G) * t, c1.B + (c2.B - c1.B) * t)
end

local function getTimeOfDayColor(hour)
	if hour >= 6 and hour < 8 then -- Sunrise
		local t = (hour - 6) / 2
		return lerpColor(NIGHT_COLOR, SUNRISE_COLOR, t)
	elseif hour >= 8 and hour < 18 then -- Day
		local t = (hour - 8) / 10
		return lerpColor(SUNRISE_COLOR, DAY_COLOR, t)
	elseif hour >= 18 and hour < 20 then -- Sunset
		local t = (hour - 18) / 2
		return lerpColor(DAY_COLOR, SUNSET_COLOR, t)
	elseif hour >= 20 and hour < 22 then -- Dusk to Night
		local t = (hour - 20) / 2
		return lerpColor(SUNSET_COLOR, NIGHT_COLOR, t)
	else -- Night
		return NIGHT_COLOR
	end
end

local function getBrightness(hour)
	if hour >= 6 and hour < 8 then -- Sunrise
		return 1 + ((hour - 6) / 2) * 2 -- 1 to 3
	elseif hour >= 8 and hour < 18 then -- Day
		return 3 -- Brightest
	elseif hour >= 18 and hour < 20 then -- Sunset
		return 3 - ((hour - 18) / 2) * 2 -- 3 to 1
	elseif hour >= 20 and hour < 22 then -- Dusk to Night
		return 1 - ((hour - 20) / 2) * 0.5 -- 1 to 0.75
	else -- Night
		return 0.75 -- Dim
	end
end

local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local function getAtmosphereDensity(hour)
	if hour >= 6 and hour < 8 then -- Sunrise
		return 0.4 + ((hour - 6) / 2) * 0.2 -- 0.4 to 0.6
	elseif hour >= 8 and hour < 18 then -- Day
		return 0.2 -- Thinnest
	elseif hour >= 18 and hour < 20 then -- Sunset
		return 0.3 + ((hour - 18) / 2) * 0.3 -- 0.3 to 0.6
	elseif hour >= 20 and hour < 22 then -- Dusk to Night
		return 0.6 -- Thickest
	else -- Night
		return 1 -- Very thick at night
	end
end

local function getAtmosphereColor(hour)
	if hour >= 6 and hour < 8 then -- Sunrise
		local t = (hour - 6) / 2
		return lerpColor(Color3.fromRGB(80, 80, 120), Color3.fromRGB(255, 170, 100), t)
	elseif hour >= 8 and hour < 18 then -- Day
		return Color3.fromRGB(255, 255, 255)
	elseif hour >= 18 and hour < 20 then -- Sunset
		local t = (hour - 18) / 2
		return lerpColor(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 120, 80), t)
	elseif hour >= 20 and hour < 22 then -- Dusk to Night
		local t = (hour - 20) / 2
		return lerpColor(Color3.fromRGB(255, 120, 80), Color3.fromRGB(80, 80, 120), t)
	else -- Night
		return Color3.fromRGB(0, 0, 0)
	end
end

local lastHour = Lighting.ClockTime
local lastDensity = Atmosphere and Atmosphere.Density or 0.3
local lastAmbient = Lighting.Ambient
local function isWrap(a, b)
	return (a < 2 and b > 23) or (b < 2 and a > 23)
end

while true do
	local now = tick()
	local elapsed = (now % DAY_LENGTH_SECONDS) / DAY_LENGTH_SECONDS
	local hour = elapsed * 24

	-- Tween ClockTime for smooth transition, except at day wrap
	local targetDensity = getAtmosphereDensity(hour)
	local targetAmbient = getTimeOfDayColor(hour)

	if math.abs(hour - lastHour) > 0.01 and hour < 23 and lastHour < 23 and not isWrap(hour, lastHour) then
		local tween = TweenService:Create(
			Lighting,
			TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
			{ ClockTime = hour }
		)
		tween:Play()
		lastHour = hour

		if Atmosphere and math.abs(targetDensity - lastDensity) > 0.01 then
			local atmoTween = TweenService:Create(
				Atmosphere,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Density = targetDensity }
			)
			atmoTween:Play()
			lastDensity = targetDensity
		elseif Atmosphere then
			Atmosphere.Density = targetDensity
			lastDensity = targetDensity
		end

		-- Tween ambient color
		if lastAmbient ~= targetAmbient then
			local ambientTween = TweenService:Create(
				Lighting,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Ambient = targetAmbient }
			)
			ambientTween:Play()
			lastAmbient = targetAmbient
		end
	else
		Lighting.ClockTime = hour
		lastHour = hour
		if Atmosphere then
			Atmosphere.Density = targetDensity
			lastDensity = targetDensity
		end
		Lighting.Ambient = targetAmbient
		lastAmbient = targetAmbient
	end

	-- Ensure after sunset is considered night for ambient
	if hour >= 22 or hour < 6 then
		Lighting.Ambient = NIGHT_COLOR
		lastAmbient = NIGHT_COLOR
	end

	Lighting.OutdoorAmbient = getTimeOfDayColor(hour)
	Lighting.Brightness = getBrightness(hour)

	if Atmosphere then
		Atmosphere.Color = getAtmosphereColor(hour)
	end

	wait(1)
end
