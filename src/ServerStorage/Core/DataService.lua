
--[[
	DO NOT USE THIS MODULE IN GAMES
	- SLIMMED DOWN FOR TESTING PURPOSES
]]

local Players = game:GetService('Players')

local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local ProfileService = ServerModules.Services.ProfileService

local ProfileCache = {}
local Loading = {}
local GameProfileStore = false

local TemplateData = {
	-- Tools
	ActiveTool = false, -- actively equipped tool
	Toolbar = {}, -- [slotNumber] = "toolID"
	Tools = {}, -- all stored tools
}

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:GetProfileFromPlayer(LocalPlayer, Yield)
	while (not ProfileCache[LocalPlayer]) and Yield do
		task.wait(0.1)
	end
	return ProfileCache[LocalPlayer]
end

function Module:_LoadDataFromUserId( UserId )
	-- if the userid's data is already being loaded, wait for it
	if Loading[ UserId ] then
		while Loading[ UserId ] do
			task.wait(0.1)
		end
		return ProfileCache[ UserId ]
	end

	-- if there is data available, return the data
	if ProfileCache[UserId] then
		return ProfileCache[UserId]
	end

	-- load the userid's data
	Loading[ UserId ] = true

	-- Load their profile from the ProfileService module
	local LoadedProfile = GameProfileStore:LoadProfileAsync( tostring(UserId), "ForceLoad" )
	if LoadedProfile then
		-- reconcile data
		LoadedProfile:Reconcile()
		-- add their user id to it
		LoadedProfile:AddUserId(UserId)
		-- if the profile is released, remove it from the cache
		LoadedProfile:ListenToRelease(function()
			ProfileCache[UserId] = nil
		end)
	end

	-- return the player's data
	Loading[ UserId ] = nil
	return LoadedProfile
end

function Module:_LoadDataFromPlayer( LocalPlayer )
	local UserId = LocalPlayer.UserId

	-- attempt to load the player's profile
	local Profile = Module:_LoadDataFromUserId( UserId )

	-- if the player's profile did not load, kick them
	if not Profile then
		LocalPlayer:Kick('Failed to load your profile data.')
		return false
	end

	-- if the profile unloads
	-- kick the player and tell them their data was loaded elsewhere
	Profile:ListenToRelease(function()
		ProfileCache[UserId] = nil
		if not Profile.Data.Banned then
			LocalPlayer:Kick('Profile has been loaded elsewhere.')
		end
	end)

	-- If they are still in the game by the time it has fully loaded
	if LocalPlayer:IsDescendantOf(Players) then
		ProfileCache[LocalPlayer.UserId] = Profile
	else
		-- if they left, release the profile
		Profile:Release()
		ProfileCache[LocalPlayer.UserId] = nil
	end

	-- return the profile
	ProfileCache[LocalPlayer] = Profile
	return Profile
end

function Module:OnPlayerAdded( LocalPlayer )
	return Module:_LoadDataFromPlayer( LocalPlayer )
end

function Module:OnPlayerRemoving( LocalPlayer )
	local activeProfile = ProfileCache[LocalPlayer]
	if activeProfile then
		ProfileCache[LocalPlayer]:Release()
	end
	ProfileCache[LocalPlayer] = nil
	Loading[LocalPlayer] = nil
end

function Module:Start()
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		task.defer(function()
			Module:OnPlayerAdded( LocalPlayer )
		end)
	end

	Players.PlayerAdded:Connect(function(LocalPlayer)
		Module:OnPlayerAdded( LocalPlayer )
	end)

	Players.PlayerRemoving:Connect(function(LocalPlayer)
		Module:OnPlayerRemoving( LocalPlayer )
	end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	GameProfileStore = ProfileService.GetProfileStore('PlayerData1', TemplateData).Mock -- NOTE: .Mock means data DOES NOT save.
end

return Module
