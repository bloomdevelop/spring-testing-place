local LightingFolder = game.Workspace:FindFirstChild("Lights") :: Folder

local Lights = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UlidModules = require(ReplicatedStorage.Luau:WaitForChild("Ulid"))

-- Create a template SurfaceLight instance and store it in ReplicatedStorage
local function createLightTemplate()
	local lightTemplate = Instance.new("SpotLight")
	lightTemplate.Name = "LightTemplate"
	lightTemplate.Brightness = 5
	lightTemplate.Face = Enum.NormalId.Bottom
	lightTemplate.Range = 60
	lightTemplate.Shadows = true
	lightTemplate.Angle = 180
	lightTemplate.Color = Color3.new(1, 1, 1)
	lightTemplate.Enabled = true
	lightTemplate.Parent = ReplicatedStorage
end

if not ReplicatedStorage:FindFirstChild("LightTemplate") then
	createLightTemplate()
end

local function initLightingSystem()
	local lightObjects = LightingFolder:GetChildren()
	local lightTemplate = ReplicatedStorage:FindFirstChild("LightTemplate")

    -- Finds whenever if it's a Part or an Model
	for _, object in ipairs(lightObjects) do
		if object:IsA("Model") then
            -- Gets the children inside of a Model instance
			local modelObjects = object:GetChildren()

            -- Find the part so we can put the LightTemplate inside of a part
			for _, part in ipairs(modelObjects) do
                if part:IsA("Part") then
					part.Material = Enum.Material.Neon
					part.Color = Color3.new(1, 1, 1)

					local lightSource = nil
					if lightTemplate then
						lightSource = lightTemplate:Clone()
						lightSource.Name = `{part.Name} ({UlidModules.createUlid()})`
						lightSource.Parent = part
					end

					table.insert(Lights, {
						Id = UlidModules.createUlid(),
						Part = part,
						SurfaceLight = lightSource,
					})
				end
			end
		end

		if object:IsA("Part") then
			object.Material = Enum.Material.Neon
			object.Color = Color3.new(1, 1, 1)

			local lightSource = nil
			if lightTemplate then
				lightSource = lightTemplate:Clone()
				lightSource.Name = `{object.Name} ({UlidModules.createUlid()})`
				lightSource.Parent = object
			end

			table.insert(Lights, {
				Id = UlidModules.createUlid(),
				Part = object,
				SurfaceLight = lightSource,
			})
		end
	end
end

initLightingSystem()

print("Initialized Lights:", Lights)
