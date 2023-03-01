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
local ActiveFishTimers = { }

local MAX_ACTIVE_FISH = 200 -- max active fish around a player
local MAX_RENDER_DISTANCE = 100 -- max render distance from the player

local function IsPointInCircle( pointXZ : Vector2, centerXZ : Vector2, radius : number ) : (boolean, Vector2)
	local Delta = (centerXZ - pointXZ)
	return Delta.Magnitude <= radius, Delta, Delta.Magnitude - radius
end

local function CreateRandomVelocity(RNG)
	return Vector2int16.new( RNG:NextNumber(), RNG:NextNumber() ).Unit * RNG:NextInteger(10, 40)/10
end

-- https://karthikkaranth.me/blog/generating-random-points-in-a-sphere/
local function RandomPointIn2DSphereInt16(RNG, r) : Vector2int16
	r = r or math.pow(RNG:NextNumber(), 1/3)
	local u = RNG:NextNumber()
	local v = RNG:NextNumber()
	local theta = u * 2.0 * math.pi
	local phi = math.acos(2.0 * v - 1.0)
	local sinTheta = math.sin(theta)
	local cosTheta = math.cos(theta)
	local sinPhi = math.sin(phi)
	local x = r * sinPhi * cosTheta
	local y = r * sinPhi * sinTheta
	return Vector2int16.new(x, y)
end

-- // Module // --
local Module = {}

--[[
	REMOTE JOBS:
	1 - create fish
	2 - time step [ :FireClient(LocalPlayer, 2, FishIndex, FishData.Position, FishData.Velocity) ]
	3 - remove fish
	4 - batch create
	5 - force position set
]]

-- remove player fish
function Module:RemoveFishIndex(LocalPlayer, FishIndex)
	local FishDataArray = ActiveFishReplicants[LocalPlayer]
	if FishDataArray then
		table.remove(FishDataArray, FishIndex)
	end
end

-- update all active fish data
function Module:UpdateActiveFishEntities(deltaTime)
	local RNG = Random.new()

	for LocalPlayer, FishDataArray in pairs( ActiveFishReplicants ) do
		-- if there is no active character data, then there is no fish nearby the player
		local CharacterData = SystemsContainer.CharacterState:UpdateCharacterData(LocalPlayer)
		if (not CharacterData) and #FishDataArray > 0 then
			ActiveFishReplicants[LocalPlayer] = { }
			continue
		end

		-- update each fish
		for FishIndex, FishData in ipairs( FishDataArray ) do
			local FuturePosition = FishData.Position + (FishData.Velocity * FishData.TimeElapsed)

			local InCircle, Delta, Mag = IsPointInCircle( FuturePosition, CharacterData.Position, MAX_RENDER_DISTANCE )
			if not InCircle then
				-- bring to the other side of the circle, and give them a random velocity
				FishData.Position = CharacterData.Position + (-Delta * Mag)
				FishData.Velocity = CreateRandomVelocity(RNG)
				FishData.TimeElapsed = 0 -- reset the time elapsed
				ActiveFishTimers[FishIndex] = 0
				FishReplicationEvent:FireClient(LocalPlayer, 2, FishIndex, FishData.Position, FishData.Velocity)
			end
			-- update the fish TimeElapsed
			FishData.TimeElapsed += deltaTime

			if (FishData.TimeElapsed - ActiveFishTimers[FishIndex]) > 0.5 then
				FishReplicationEvent:FireClient(
					LocalPlayer,
					5,
					FishIndex,
					FuturePosition,
					FishData.TimeElapsed
				)
			end
		end

		-- if we have reached the max number of fishes,
		-- skip the rest of the code in the loop
		local dataLen = #FishDataArray
		if dataLen >= MAX_ACTIVE_FISH then
			continue
		end

		-- create a bunch of fishes in this cycle and append to the table
		local amountToCreate = math.min(3, MAX_ACTIVE_FISH - dataLen)
		for _ = 1, amountToCreate do
			-- place the fish in a sphere, towards the edge, near the player
			local Data = {
				Position = RandomPointIn2DSphereInt16(RNG, MAX_RENDER_DISTANCE * RNG:NextNumber(0.8, 1)),
				Velocity = CreateRandomVelocity(RNG),
				TimeElapsed = 0,
			}
			table.insert(ActiveFishTimers, 0)
			table.insert(FishDataArray, Data)
			FishReplicationEvent:FireClient(LocalPlayer, 1, Data.Position, Data.Velocity)
		end
	end
end

-- add player's fish data
function Module:OnPlayerAdded(LocalPlayer)
	ActiveFishTimers[LocalPlayer] = { }
	ActiveFishReplicants[LocalPlayer] = { }
end

-- clear player's fish data
function Module:OnPlayerRemoving(LocalPlayer)
	ActiveFishReplicants[LocalPlayer] = nil
	ActiveFishTimers[LocalPlayer] =  nil
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

	RunService.Heartbeat:ConnectParallel(function(deltaTime)
		-- update all available fish for all players
		Module:UpdateActiveFishEntities(deltaTime)
	end)

	-- when the client asks for the fish data, send them the full table
	FishReplicationEvent.OnServerEvent:Connect(function(LocalPlayer)
		local Replicants = ActiveFishReplicants[LocalPlayer]
		if not Replicants then
			return
		end
		FishReplicationEvent:FireAllClients(LocalPlayer, 4, Replicants)
	end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
