-- Variables to control the wind randomization.
-- Adjust these values to change the speed and frequency of the wind changes.
local MIN_WIND_SPEED = 0
local MAX_WIND_SPEED = 30
local MIN_UPDATE_TIME = 30
local MAX_UPDATE_TIME = 60
local TRANSITION_TIME = 10 -- Time in seconds for the wind to transition to a new state

-- Main loop to continuously update the wind.
while true do
	-- Wait for a random duration before starting the next wind transition.
	task.wait(math.random(MIN_UPDATE_TIME, MAX_UPDATE_TIME))
	
	-- Get the current wind Vector3.
	local currentWind = workspace.GlobalWind
	
	-- Generate a random speed within the defined range.
	local newSpeed = math.random(MIN_WIND_SPEED, MAX_WIND_SPEED)
	
	-- Generate a random direction vector for the wind.
	local newDirectionX = math.random(-100, 100)
	local newDirectionZ = math.random(-100, 100)
	
	-- Create the target wind Vector3.
	local targetWind = Vector3.new(newDirectionX, 0, newDirectionZ).Unit * newSpeed
	
	-- Smoothly transition the wind from the current state to the new target state.
	local startTime = os.clock()
	local elapsedTime = 0
	
	while elapsedTime < TRANSITION_TIME do
		-- Calculate the alpha for linear interpolation (lerp).
		-- This value goes from 0 to 1 over the transition time.
		local alpha = elapsedTime / TRANSITION_TIME
		
		-- Use lerp to create a smooth transition between the current and target wind.
		workspace.GlobalWind = currentWind:Lerp(targetWind, alpha)
		
		-- Wait for a small amount of time to create a smooth step.
		task.wait(1/60) -- Waits for approximately 1/60th of a second
		
		-- Update the elapsed time.
		elapsedTime = os.clock() - startTime
	end
	
	-- Ensure the wind reaches the final target value.
	workspace.GlobalWind = targetWind
end