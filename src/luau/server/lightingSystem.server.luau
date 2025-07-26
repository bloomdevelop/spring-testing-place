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
    lightTemplate.Color = Color3.new(1, 1, 1) -- White
    lightTemplate.Enabled = true
    lightTemplate.Parent = ReplicatedStorage
end

if not ReplicatedStorage:FindFirstChild("LightTemplate") then
    createLightTemplate()
end

local function initLightingSystem()
    local lightObjects = LightingFolder:GetChildren()
    local lightTemplate = ReplicatedStorage:FindFirstChild("LightTemplate")

    for _, light in ipairs(lightObjects) do
        if light:IsA("Part") then
            light.Material = Enum.Material.Neon
            light.Color = Color3.new(1, 1, 1)

            local lightSource = nil
            if lightTemplate then
                lightSource = lightTemplate:Clone()
                lightSource.Name = `{light.Name} ({UlidModules.createUlid()})`
                lightSource.Parent = light
            end

            table.insert(Lights, {
                Id = UlidModules.createUlid(),
                Part = light,
                SurfaceLight = lightSource,
            })
        end
    end
end

initLightingSystem()

print("Initialized Lights:", Lights)