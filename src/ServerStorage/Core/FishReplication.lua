local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local QuadTreeClassModule = ReplicatedModules.Classes.QuadTree
local SimpleBitModule = ReplicatedModules.Utility.SimpleBit

local RemoteService = ReplicatedModules.Services.RemoteService
local FishReplicationEvent = RemoteService:GetRemote('FishReplicateEvent', 'RemoteEvent', false)

local SystemsContainer = {}

local ActiveFishReplicants = { }

local MAX_ACTIVE_FISH = 200 -- max active fish around a player
local MAX_RENDER_DISTANCE = 100 -- max render distance from the player

-- // Module // --
local Module = {}

-- compress update data for the remotes
--[[ X, X, X, ... ]]

-- update all active fish data
function Module:UpdateActiveFishEntities()

	for LocalPlayer, FishDataMap in pairs( ActiveFishReplicants ) do

		-- update each fish
		for FishUUID, FishData in pairs( FishDataMap ) do

		end

	end

end

-- add player's fish data
function Module:OnPlayerAdded(LocalPlayer)
	ActiveFishReplicants[LocalPlayer] = { }
end

-- clear player's fish data
function Module:OnPlayerRemoving(LocalPlayer)
	if ActiveFishReplicants[LocalPlayer] then
		ActiveFishReplicants[LocalPlayer] = nil
	end
end

function Module:Start()
	Players.PlayerRemoving:Connect(function(LocalPlayer)
		Module:OnPlayerRemoving(LocalPlayer)
	end)

	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		task.defer(function()
			Module:OnPlayerAdded(LocalPlayer)
		end)
	end

	Players.PlayerAdded:Connect(function(LocalPlayer)
		Module:OnPlayerAdded(LocalPlayer)
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		-- update all available fish for all players
		Module:UpdateActiveFishEntities()
	end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
