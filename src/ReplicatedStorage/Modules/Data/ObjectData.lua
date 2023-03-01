local DefaultToolCFrame = CFrame.new(0,0,0)
local DefaultToolCameraFaceCenter = CFrame.new(Vector3.new(2, 0, 0), DefaultToolCFrame.Position)

local DefaultBoatCFrame = CFrame.new(-1,0,0)
local DefaultBoatCameraFaceCenter = CFrame.new(Vector3.new(4, 0, 0), DefaultBoatCFrame.Position)

-- // Module // --
local Module = {}

function Module:RequiredExperienceToRankUp(CurrentRank)
	return math.floor( ((CurrentRank / 2) * 35) + (50 * math.pow(CurrentRank, 1.15)) + 5)
end

Module.Fishes = {
	-- Rank 0
	_YellowFish = {
		ReqRank = 0,
		ExpAmount = 1,
		SellPrice = 4,
		WeightedChance = 40,

		Model = 'YellowFish',

		Display = {
			Title = {
				Text = 'Yellow Fish',
				Color = Color3.fromRGB(255, 255, 0),
			},
		},

		ModelCFrame = DefaultToolCFrame,
		CameraCFrame = DefaultToolCameraFaceCenter,
	},

	-- Rank 1
	_BlueFish = {
		ReqRank = 1,
		ExpAmount = 2,
		SellPrice = 8,
		WeightedChance = 25,

		Model = 'BlueFish',

		Display = {
			Title = {
				Text = 'Blue Fish',
				Color = Color3.fromRGB(0, 160, 188),
			},
		},

		ModelCFrame = DefaultToolCFrame,
		CameraCFrame = DefaultToolCameraFaceCenter,
	},

	_BlueTangFish = {
		ReqRank = 1,
		ExpAmount = 3,
		SellPrice = 14,
		WeightedChance = 12,

		Model = 'BlueTangFish',

		Display = {
			Title = {
				Text = 'Blue Tang Fish',
				Color = Color3.fromRGB(0, 160, 188),
			},
		},

		ModelCFrame = DefaultToolCFrame,
		CameraCFrame = DefaultToolCameraFaceCenter,
	},

	-- Rank 2
	_ClownFish = {
		ReqRank = 2,
		ExpAmount = 5,
		SellPrice = 25,
		WeightedChance = 12,

		Model = 'ClownFish',

		Display = {
			Title = {
				Text = 'Clown Fish',
				Color = Color3.fromRGB(188, 144, 0),
			},
		},

		ModelCFrame = DefaultToolCFrame,
		CameraCFrame = DefaultToolCameraFaceCenter,
	},

	_VioletFish = {
		ReqRank = 2,
		ExpAmount = 6,
		SellPrice = 35,
		WeightedChance = 3,

		Model = 'VioletFish',

		Display = {
			Title = {
				Text = 'Violet Fish',
				Color = Color3.fromRGB(85, 0, 188),
			},
		},

		ModelCFrame = DefaultToolCFrame,
		CameraCFrame = DefaultToolCameraFaceCenter,
	},

	-- Rank 3
	_RedFish = {
		ReqRank = 3,
		ExpAmount = 12,
		SellPrice = 65,
		WeightedChance = 10,

		Model = 'RedFish',

		Display = {
			Title = {
				Text = 'Red Fish',
				Color = Color3.fromRGB(188, 0, 0),
			},
		},

		ModelCFrame = DefaultToolCFrame,
		CameraCFrame = DefaultToolCameraFaceCenter,
	},

	_CebraFish = {
		ReqRank = 3,
		ExpAmount = 15,
		SellPrice = 65,
		WeightedChance = 10,

		Model = 'CebraFish',

		Display = {
			Title = {
				Text = 'Cebra Fish',
				Color = Color3.fromRGB(209, 209, 209),
			},
		},

		ModelCFrame = DefaultToolCFrame,
		CameraCFrame = DefaultToolCameraFaceCenter,
	},

	_BlackyFish = {
		ReqRank = 3,
		ExpAmount = 18,
		SellPrice = 85,
		WeightedChance = 6,

		Model = 'BlackyFish',

		Display = {
			Title = {
				Text = 'Blacky Fish',
				Color = Color3.fromRGB(78, 78, 78),
			},
		},

		ModelCFrame = DefaultToolCFrame,
		CameraCFrame = DefaultToolCameraFaceCenter,
	},

	-- Rank 4
	_PufferFish = {
		ReqRank = 4,
		ExpAmount = 22,
		SellPrice = 120,
		WeightedChance = 3,

		Model = 'PufferFish',

		Display = {
			Title = {
				Text = 'Puffer Fish',
				Color = Color3.fromRGB(215, 196, 48),
			},
		},

		ModelCFrame = DefaultToolCFrame,
		CameraCFrame = DefaultToolCameraFaceCenter,
	},

}

Module.Tools = {
	FishingRod1 = {
		Type = 'Rod',

		Rank = 1,
		Quantity = 1, -- Amount of fish
		Duration = {4, 8}, -- min, max
		BuyPrice = 250,
		Model = 'FishingRod1',

		Display = {
			Title = {
				Text = 'Basic Fishing Rod',
				TextColor3 = Color3.fromRGB(255,255,255),
			},
			Icon = {
				Image = 'rbxassetid://137511721',
			}
		},

		-- FOR THE TOOLBAR / INVENTORY
		CameraCFrame = DefaultToolCameraFaceCenter,
		ModelCFrame = DefaultToolCFrame * CFrame.new(-3, -2.5, 1) * CFrame.Angles( math.rad(-105), 0, 0 ),
		-- FOR THE SHOP
		ShopRotation = CFrame.new(3, -2, 0) * CFrame.Angles( math.rad(-90), math.rad(-75), math.rad(90) ),
		-- FOR THE PLAYER'S HAND
		MotorOffset = CFrame.Angles( math.rad(180), 0, math.rad(-180) ) * CFrame.new(0, -0.2, -0.1),
	},

	FishingRod2 = {
		Type = 'Rod',

		Rank = 2,
		Quantity = 1, -- Amount of fish
		Duration = {3.5, 7.5}, -- min, max
		BuyPrice = 1000,
		Model = 'FishingRod2',

		Display = {
			Title = {
				Text = 'Sturdy Fishing Rod',
				TextColor3 = Color3.fromRGB(255,255,255),
			},
			Icon = {
				Image = 'rbxassetid://137511721',
			}
		},

		-- FOR THE TOOLBAR / INVENTORY
		CameraCFrame = DefaultToolCameraFaceCenter,
		ModelCFrame = DefaultToolCFrame * CFrame.new(-3, -2.5, 1) * CFrame.Angles( math.rad(-105), 0, 0 ),
		-- FOR THE SHOP
		ShopRotation = CFrame.new(3, -2, 0) * CFrame.Angles( math.rad(-90), math.rad(-75), math.rad(90) ),
		-- FOR THE PLAYER'S HAND
		MotorOffset = CFrame.Angles( math.rad(180), 0, math.rad(-180) ) * CFrame.new(0, -0.2, -0.1),
	},

	FishingRod3 = {
		Type = 'Rod',

		Rank = 2,
		Quantity = 1, -- Amount of fish
		Duration = {3, 7}, -- min, max
		BuyPrice = 2500,
		Model = 'FishingRod3',

		Display = {
			Title = {
				Text = 'Steel Fishing Rod',
				TextColor3 = Color3.fromRGB(255,255,255),
			},
			Icon = {
				Image = 'rbxassetid://137511721',
			}
		},

		-- FOR THE TOOLBAR / INVENTORY
		CameraCFrame = DefaultToolCameraFaceCenter,
		ModelCFrame = DefaultToolCFrame * CFrame.new(-3, -2.5, 1) * CFrame.Angles( math.rad(-105), 0, 0 ),
		-- FOR THE SHOP
		ShopRotation = CFrame.new(3, -2, 0) * CFrame.Angles( math.rad(-90), math.rad(-75), math.rad(90) ),
		-- FOR THE PLAYER'S HAND
		MotorOffset = CFrame.Angles( math.rad(180), 0, math.rad(-180) ) * CFrame.new(0, -0.2, -0.1),
	},
}

function Module:GetFishDataFromId(fishId)
	return Module.Fishes[ fishId ]
end

function Module:GetPossibleFishes(fishRank)
	local fishIDs = {}
	for fishID, fishData in pairs( Module.Fishes ) do
		if fishData.Rank <= fishRank then
			table.insert(fishIDs, fishID)
		end
	end
	return fishIDs
end

function Module:CountFishes( fishTable )
	local count = 0
	for _, amount in pairs( fishTable ) do
		count += amount
	end
	return count
end

return Module
