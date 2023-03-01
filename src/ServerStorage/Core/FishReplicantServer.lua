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
local MAX_RENDER_DISTANCE = 80 -- max render distance from the player
local FORCE_UPDATE_INTERVAL = 1

local function IsPointInCircle( pointXZ : Vector2, centerXZ : Vector2, radius : number ) : (boolean, Vector2)
	return (centerXZ - pointXZ ).Magnitude <= radius
end

local function CreateRandomVelocity()
	local RNG = Random.new()
	return Vector2.new( RNG:NextNumber(), RNG:NextNumber() ) * RNG:NextInteger(10, 40)/10
end

-- https://karthikkaranth.me/blog/generating-random-points-in-a-sphere/
local function RandomPointIn2DSphere(r) : Vector2
	local RNG = Random.new()
	local u = RNG:NextNumber()
	local v = RNG:NextNumber()
	local theta = u * 2.0 * math.pi
	local phi = math.acos(2.0 * v - 1.0)
	local sinTheta = math.sin(theta)
	local cosTheta = math.cos(theta)
	local sinPhi = math.sin(phi)
	r = r or math.pow(RNG:NextNumber(), 1/3)
	local x = r * sinPhi * cosTheta
	local y = r * sinPhi * sinTheta
	return Vector2.new(x, y)
end

local function Vector2_to_int16XZ(Vec2)
	return Vector2int16.new(Vec2.X * 33, Vec2.Y * 33)
end

local function RoundVector2(Vec2, places)
	local pow10 = math.pow(10, places or 2)
	return Vector2.new( math.floor(Vec2.X * pow10) / pow10, math.floor(Vec2.Y * pow10) / pow10 )
end

-- // Module // --
local Module = {}

--[[
	REMOTE JOBS:
	1 - create fish
	2 - time step
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

-- get the fish's position
function Module:GetFishPosition( fishData )
	return fishData.Position + (fishData.Velocity * fishData.TimeElapsed)
end

function Module:UpdateActiveFishEntities(deltaTime)
	local RNG = Random.new()

	for LocalPlayer, FishDataArray in pairs( ActiveFishReplicants ) do
		-- if there is no active character data, then there is no fish nearby the player
		local CharacterData = SystemsContainer.CharacterState:GetCharacterData(LocalPlayer)
		if (not CharacterData) or (not CharacterData.Position2D) then
			-- clear active fishes for the player
			if #FishDataArray > 0 then
				ActiveFishReplicants[LocalPlayer] = { }
			end
			continue
		end

		-- update each fish
		-- print(#FishDataArray)
		for FishIndex, FishData in ipairs( FishDataArray ) do
			local FuturePosition = Module:GetFishPosition( FishData )

			local InCircle = IsPointInCircle( FuturePosition, CharacterData.Position2D, MAX_RENDER_DISTANCE )
			if not InCircle then
				-- bring to the other side of the circle, and give them a random velocity
				local randomPoint = RandomPointIn2DSphere(MAX_RENDER_DISTANCE * RNG:NextNumber(0.9, 1))
				FishData.Position = CharacterData.Position2D + randomPoint
				FishData.Velocity = CreateRandomVelocity()
				FishData.TimeElapsed = 0 -- reset the time elapsed
				ActiveFishTimers[FishIndex] = 0
				FishReplicationEvent:FireClient( LocalPlayer, 2, FishIndex, RoundVector2(FishData.Position, 2), Vector2_to_int16XZ(FishData.Velocity) )
			end

			-- update the fish TimeElapsed
			FishData.TimeElapsed += deltaTime
			if (FishData.TimeElapsed - ActiveFishTimers[FishIndex]) > FORCE_UPDATE_INTERVAL then
				ActiveFishTimers[FishIndex] = FishData.TimeElapsed
				FishReplicationEvent:FireClient( LocalPlayer, 5, FishIndex, RoundVector2(FuturePosition, 2) )
			end
		end

		-- if we have reached the max number of fishes,
		-- skip the rest of the code in the loop
		local dataLen = #FishDataArray
		if dataLen >= MAX_ACTIVE_FISH then
			continue
		end

		-- create a bunch of fishes in this cycle and append to the table
		local amountToCreate = math.min( 1 + math.floor( MAX_ACTIVE_FISH / 20 ), MAX_ACTIVE_FISH - dataLen)

		for _ = 1, amountToCreate do
			-- place the fish in a sphere, towards the edge, near the player
			local randomPoint = RandomPointIn2DSphere(MAX_RENDER_DISTANCE * RNG:NextNumber(0.9, 1))
			local Data = {
				Position = CharacterData.Position2D + randomPoint,
				Velocity = CreateRandomVelocity(),
				TimeElapsed = 0,
			}
			table.insert(ActiveFishTimers, 0)
			table.insert(FishDataArray, Data)
			FishReplicationEvent:FireClient(LocalPlayer, 1, #FishDataArray, RoundVector2(Data.Position, 2), Vector2_to_int16XZ(Data.Velocity))
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

	task.spawn(function()
		while true do
			local deltaTime = task.wait()
			-- update all available fish for all players
			Module:UpdateActiveFishEntities(deltaTime)
		end
	end)

	-- when the client asks for the fish data, send them the full table
	FishReplicationEvent.OnServerEvent:Connect(function(LocalPlayer)
		if not ActiveFishReplicants[LocalPlayer] then
			return
		end

		local Replicants = { }
		for _, fishData in ipairs( ActiveFishReplicants[LocalPlayer] or { } ) do
			table.insert(Replicants, RoundVector2(fishData.Position, 1))
			table.insert(Replicants, Vector2_to_int16XZ(fishData.Velocity))
		end
		FishReplicationEvent:FireClient(LocalPlayer, 4, Replicants)
	end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
