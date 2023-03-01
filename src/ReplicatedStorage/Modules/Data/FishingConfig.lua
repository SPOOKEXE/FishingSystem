
local Module = {}

Module.NPCs = {
	Fisher1 = 'rbxassetid://7356729066',
	Fisher2 = 'rbxassetid://7356776965',
	Fisher3 = 'rbxassetid://7356776965',

	FisherSeller = 'rbxassetid://7716546146',
	BoatShopNPC = 'rbxassetid://7808982270',
	CounterWoman = 'rbxassetid://7808998844',
}

Module.CoreFishingRod = {
	Default = {
		RunOverride = 'rbxassetid://7820505726',
		HoldIdle = 'rbxassetid://7820525686',
		CastLine = 'rbxassetid://7820538554',
		CastedIdle = 'rbxassetid://7820542166',
		ReelLine = 'rbxassetid://7820545934',
	},
}

function Module:GetCoreRodAnimation( Category, AnimName )
	local TargetAnimTable = Module.CoreFishingRod[Category]
	return TargetAnimTable and TargetAnimTable[AnimName] or Module.CoreFishingRod.Default[AnimName]
end

return Module
