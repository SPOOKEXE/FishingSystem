
-- // Module // --
local Module = {}

function Module:GetWeighted(dataTable, doubleChanceForLowers)
	--[[
		local dataTable = {
			{"A", 5},
			{"B", 2},
			{"C", 2},
			{"D", 3},
			{"E", 3},
			{"F", 3},
			{"G", 1},
			{"H", 8},
			{"I", 12},
			{"J", 2}
		}
	]]

	local TotalWeight = 0
	for _,ItemData in pairs(dataTable) do
		TotalWeight = TotalWeight + ItemData[2]
	end

	if doubleChanceForLowers then
		local newDataTable = {}
		local newTotalWeight = 0
		for index = 1, #dataTable do
			local weight = dataTable[index][2]
			weight *= weight<=(TotalWeight/10) and 2 or 1
			newDataTable[index] = {dataTable[index][1], weight}
			newTotalWeight += weight
		end
		dataTable = newDataTable
		TotalWeight = newTotalWeight
	end

	local Chance = math.random(TotalWeight)
	local Counter = 0
	for _,ItemData in pairs(dataTable) do
		Counter = Counter + ItemData[2]
		if Chance <= Counter then
			return ItemData[1]
		end
	end
	return nil
end

return Module