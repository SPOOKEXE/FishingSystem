local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

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

local function Vector2int16_toVec2( vec2int16 )
	return Vector2.new( vec2int16.X / 10, vec2int16.Y / 10 )
end

-- // Module // --
local Module = {}

local baseBlock = Instance.new('Part')
baseBlock.Anchored = true
baseBlock.CastShadow = false
baseBlock.CanCollide = false
baseBlock.CanTouch = false
baseBlock.CanQuery = false
baseBlock.Material = Enum.Material.SmoothPlastic
baseBlock.TopSurface = Enum.SurfaceType.SmoothNoOutlines
baseBlock.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
baseBlock.Size = Vector3.new(0.5, 0.5, 0.5)

local ActiveBlocks = { }

function Module:UpdateActiveFishEntities(deltaTime)
	for fishIndex, FishData in ipairs( ActiveFishEntities ) do
		FishData.Position += (FishData.Velocity * deltaTime)
		-- move the debug block
		local Block = ActiveBlocks[fishIndex]
		if not Block then
			Block = baseBlock:Clone()
			Block.Name = fishIndex
			Block.Parent = workspace.Terrain
			ActiveBlocks[fishIndex] = Block
		end
		-- find the ocean surface near the player and position the fish (otherwise put them really far away)
		Block.Position = Vector3.new( FishData.Position.X, 3, FishData.Position.Y )
	end

	while #ActiveBlocks > #ActiveFishEntities do
		table.remove(ActiveBlocks, #ActiveBlocks)
	end
end

function Module:OnClientEvent( Job, ... )
	local Args = {...}

	if Job == 1 then -- create fish

		local delta = LocalPlayer:GetNetworkPing() * 2
		ActiveFishEntities[ Args[1] ] = {
			Position = Args[2],
			Velocity = Vector2int16_toVec2(Args[3]),
			TimeElapsed = (Args[4] and Args[4] + delta or delta),
		}

	elseif Job == 2 then -- update fish

		local delta = LocalPlayer:GetNetworkPing() * 2

		local Data = ActiveFishEntities[ Args[1] ]
		Data.Velocity = Vector2int16_toVec2(Args[3])
		Data.Position = Args[2] + (Data.Velocity * delta)

	elseif Job == 3 then -- remove fish

		table.remove( ActiveFishEntities, Args[1] )

	elseif Job == 4 then -- batch set

		local Array = Args[1]
		local delta = LocalPlayer:GetNetworkPing() * 2
		for fishIndex = 1, #Array, 3 do
			local Position, Velocity, TimeElapsed = Array[fishIndex], Array[fishIndex + 1], Array[fishIndex + 2]
			ActiveFishEntities[ fishIndex ] = {
				Position = Position + (Velocity * delta),
				Velocity = Velocity,
				TimeElapsed = (TimeElapsed + delta),
			}
		end

	elseif Job == 5 then -- force position set

		local Data = ActiveFishEntities[ Args[1] ]
		Data.Position = Args[2]
		Data.TimeElapsed = Args[3] + LocalPlayer:GetNetworkPing()

	end
end

function Module:Start()
	task.spawn(function()
		while true do
			local deltaTime = task.wait()
			-- update all available fish for all players
			Module:UpdateActiveFishEntities(deltaTime)
		end
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
