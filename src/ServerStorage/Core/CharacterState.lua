local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local SystemsContainer = {}

local CharacterData = { }

-- // Module // --
local Module = {}

function Module:ClearCharacterData(LocalPlayer)
	CharacterData[LocalPlayer] = nil
end

function Module:UpdateCharacterData(LocalPlayer)
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildWhichIsA('Humanoid')
	local PivotPoint = Character and Character:GetPivot()
	if (not Humanoid) or (not PivotPoint) then
		Module:ClearCharacterData(LocalPlayer)
		return
	end
	-- update character data
	if CharacterData[LocalPlayer] then
		CharacterData[LocalPlayer].Position = PivotPoint.Position
	else
		CharacterData[LocalPlayer] = { Position = PivotPoint.Position }
	end
end

function Module:OnPlayerAdded(LocalPlayer)
	task.defer(function()
		if LocalPlayer.Character then
			Module:UpdateCharacterData(LocalPlayer)
		end
	end)

	LocalPlayer.CharacterAdded:Connect(function()
		Module:UpdateCharacterData(LocalPlayer)
	end)
end

function Module:OnPlayerRemoving(LocalPlayer)
	Module:ClearCharacterData(LocalPlayer)
end

function Module:Start()
	RunService.Heartbeat:Connect(function()
		for LocalPlayer, _ in ipairs( Players:GetPlayers() ) do
			Module:UpdateCharacterData(LocalPlayer)
		end
	end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module

