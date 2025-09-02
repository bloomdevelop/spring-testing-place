local IK = require(script.Movement)
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		IK:Add(Character)
	end)
end)

for _, Player in Players:GetPlayers() do
	if Player.Character then
		IK:Add(Player.Character)
	end
	Player.CharacterAdded:Connect(function(Character)
		IK:Add(Character)
	end)
end