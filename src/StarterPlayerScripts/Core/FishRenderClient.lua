local RunService = game:GetService('RunService')

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalModules = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local RemoteService = ReplicatedModules.Services.RemoteService
local FishReplicationEvent = RemoteService:GetRemote('FishReplicateEvent', 'RemoteEvent', false)

local SimpleBitModule = ReplicatedModules.Utility.SimpleBit

local SystemsContainer = {}

local ActiveFishEntities = { }

-- // Module // --
local Module = {}

function Module:UpdateActiveFishEntities(deltaTime)
	for _, FishData in ipairs( ActiveFishEntities ) do
		FishData.Position += (FishData.Velocity * deltaTime)
	end
end

function Module:OnClientEvent( Job, ... )
	local Args = {...}

	if Job == 1 then -- create fish

		table.insert(ActiveFishEntities, {
			Position = Args[1],
			Velocity = Args[2],
			TimeElapsed = LocalPlayer:GetNetworkPing(),
		})
	elseif Job == 2 then -- update fish

		local Data = ActiveFishEntities[ Args[1] ]
		Data.Position = Args[2]
		Data.Velocity = Args[3]

	elseif Job == 3 then -- remove fish

		table.remove( ActiveFishEntities, Args[1] )

	elseif Job == 4 then -- batch set

		ActiveFishEntities = Args[1]
		for _, FishEntity in ipairs( ActiveFishEntities ) do
			local delta = LocalPlayer:GetNetworkPing()
			FishEntity.TimeElapsed += delta
			FishEntity.Position += FishEntity.Velocity * delta
		end

	elseif Job == 5 then -- force position set

		local Data = ActiveFishEntities[ Args[1] ]
		Data.Position = Args[2]
		Data.TimeElapsed = Args[3] + LocalPlayer:GetNetworkPing()

	end
end

function Module:Start()
	RunService.Heartbeat:Connect(function(deltaTime)
		Module:UpdateActiveFishEntities(deltaTime)
	end)

	FishReplicationEvent.OnClientEvent:Connect(function(...)
		Module:OnClientEvent( ... )
	end)

	FishReplicationEvent:FireServer() -- ask the server for all the latest info B)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
