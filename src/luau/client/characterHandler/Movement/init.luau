local RunService = game:GetService("RunService")
local IKHandler = require(script.IKHandler)
local Intensity = 15 -- 7 or 10 Is optimal -- 15 Is run -- 5 Is optimal(OLD) -- 2 idk
local CurrentIntensity = 0
local Offsets = { Right = CFrame.new(0.5, -1, 0), Left = CFrame.new(-0.5, -1, 0) }
local AttachmentPositions: { [string]: Vector3 } = {
	[`RightLegStart`] = Vector3.new(0.5, -1, 0),
	[`RightLegEnd`] = Vector3.new(0.5, -3, 0),
	[`LeftLegStart`] = Vector3.new(-0.5, -1, 0),
	[`LeftLegEnd`] = Vector3.new(-0.5, -3, 0),
}
local Process = {}

local InitedCharacters = {}

local function Lerp(A: number, B: number, T: number): number
	return A + (B - A) * T
end

function Process:Add(Character: Model, IgnoreList: { Instance }): ()
	local CharacterIndex = table.find(InitedCharacters, Character)
	if CharacterIndex then
		return
	end
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid") or Character:WaitForChild(`Humanoid`) :: Humanoid
	local RootPart: BasePart = Humanoid and Humanoid.RootPart :: BasePart
	local Torso: BasePart = Character:WaitForChild("Torso") :: BasePart
	local IK = IKHandler.New(Character)
	local RightHip = IK.Motor6Ds["Right Hip"]
	local LeftHip = IK.Motor6Ds["Left Hip"]
	local RootJoint = IK.Motor6Ds.RootJoint

	local Attachments = {}

	table.insert(InitedCharacters, Character)

	CharacterIndex = table.find(InitedCharacters, Character)

	for i, v in AttachmentPositions do
		local Attachment = Instance.new(`Attachment`)
		Attachment.Parent = Torso
		Attachment.Position = v
		Attachment.Name = i
		Attachments[i] = Attachment
	end

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { Character }
	if IgnoreList then
		for _, v in IgnoreList do
			params:AddToFilter(v)
		end
	end

	local Connection = RunService.RenderStepped:Connect(function(DeltaTime: number)
		local NewDelta = DeltaTime * 60
		local Cycle = Vector3.zero
		local TargetSpeed = Humanoid.WalkSpeed / 1.5
		local CastRight =
			workspace:Raycast((Humanoid.RootPart.CFrame * Offsets.Right).Position, Vector3.yAxis * -3, params)
		local CastLeft =
			workspace:Raycast((Humanoid.RootPart.CFrame * Offsets.Left).Position, Vector3.yAxis * -3, params)
		local Direction = Humanoid.RootPart.CFrame:VectorToObjectSpace(Humanoid.MoveDirection)
		local Backward = Direction.Z > 0.5
		local CanUse = true

		if Direction.Magnitude > 0.5 then
			Cycle = Cycle:Lerp(
				Vector3.new(
					math.cos(tick() * TargetSpeed) * CurrentIntensity * -Direction.X,
					math.sin(tick() * TargetSpeed) * (CurrentIntensity / 3),
					math.cos(tick() * TargetSpeed) * CurrentIntensity * (Backward and -1 or 1) * math.abs(Direction.Z)
				),
				0.25
			)

			Attachments.RightLegEnd.Position = AttachmentPositions.RightLegEnd + Cycle
			Attachments.LeftLegEnd.Position = AttachmentPositions.LeftLegEnd - Cycle
		else
			Attachments.RightLegEnd.Position = AttachmentPositions.RightLegEnd
			Attachments.LeftLegEnd.Position = AttachmentPositions.LeftLegEnd
		end

		if CastRight then
			Attachments.RightLegEnd.Position += Vector3.yAxis * (2 - CastRight.Distance)
		end

		if CastLeft then
			Attachments.LeftLegEnd.Position += Vector3.yAxis * (2 - CastLeft.Distance)
		end

		if not CanUse then
			Attachments.RightLegEnd.Position = AttachmentPositions.RightLegEnd
			Attachments.LeftLegEnd.Position = AttachmentPositions.LeftLegEnd
		else
			RightHip.Transform = CFrame.identity
			LeftHip.Transform = CFrame.identity
		end

		CurrentIntensity = Lerp(
			CurrentIntensity,
			Intensity * math.clamp((RootPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude / 10, 0, 1),
			0.3 * NewDelta
		)

		RootJoint.C0 = RootJoint.C0:Lerp(
			IK.C0s.RootJoint * CFrame.Angles(-math.rad(Direction.Z * (6 * 2)), -math.rad(Direction.X * 8), 0),
			0.2
		)
		RightHip.C0 = RightHip.C0:Lerp(IK:LegIK(`Right`, Attachments.RightLegEnd.WorldPosition), 0.13)
		LeftHip.C0 = LeftHip.C0:Lerp(IK:LegIK(`Left`, Attachments.LeftLegEnd.WorldPosition), 0.13)
	end)
	Humanoid.Died:Once(function()
		Connection:Disconnect()
		table.remove(InitedCharacters, CharacterIndex)
	end)
end

return Process
