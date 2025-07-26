-- Typing error, but not necessarily a problem anyway
game.ReplicatedFirst:RemoveDefaultLoadingScreen()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages:FindFirstChild("react-roblox"))
local TipGenerator = require(ReplicatedStorage.Luau.TipGenerator)

local loaded = false
local function LoadingScreen()
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
	}, {
		TextLabel = React.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = loaded and "Loaded!" or "Loading...",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = false,
			TextSize = 32,
			LayoutOrder = 1,
		}),
		TipLabel = React.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.1),
			Position = UDim2.fromScale(0, 0.9),
			BackgroundTransparency = 1,
			Text = TipGenerator.generateTip(),
			TextColor3 = Color3.new(.5, .5, .5),
			TextScaled = false,
			TextSize = 18,
			LayoutOrder = 2,
		}),
	})
end

local handle = Instance.new("ScreenGui")
handle.Name = "LoadingScreen"
handle.IgnoreGuiInset = true
handle.ResetOnSpawn = false

local root = ReactRoblox.createRoot(handle)
root:render(React.createElement(LoadingScreen, {}, {}))

local function onLoadingComplete()
	root:unmount()
	handle:Destroy()
end

handle.Parent = PlayerGui

repeat
	wait(1)
until game:IsLoaded()
loaded = true
root:render(React.createElement(LoadingScreen, {}, {}))
wait(2)
onLoadingComplete()
