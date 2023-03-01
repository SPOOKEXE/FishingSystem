--[[
	[AUTHOR]: @coolalex1835:
	[NAME]: SimpleBit Module
		[EDITOR]: @SPOOK_EXE
		[NAME]: SimpleBit Optimized

	Remember to check if there are any updates for the module on the thread in the devforum!
	[DEVFORUM THREAD]: https://devforum.roblox.com/t/open-source-simplebit-bit32-made-simple/1632986

	NEW VERSION: 1st March 2023

	[CONTENT INFO]
	Converters:
		Converts a specified type of data to another.
	Check:
		Functions that check for a property from the input.
	Arithmetic:
		Bit32 Powered arithmetic.
	Bit-Packing:
		Functions for Bit32 bit-packing & bit-masking.
]]

local SimpleBit = {}

local function JoinValuesToString(seperator : string, ... : number...) : string
	local Values = { ... }
	for index, v in ipairs( Values ) do
		Values[index] = tostring(v)
	end
	return table.concat( Values, seperator )
end

local function SToBinP(n : number) : string
	local Sequence = ''
	for c = 0, 7 do
		Sequence..= bit32.extract(n,c,1)
	end
	return string.reverse(Sequence)
end

--/// Public Functions // --
function SimpleBit.IntToBin(n : number) : string
	local Sequence = ''
	for c = 0, 31 do
		Sequence ..= bit32.extract(n,c,1)
	end
	return string.reverse(Sequence)
end

function SimpleBit.BinToInt(BinSequence : string) : number
	return tonumber(BinSequence, 2)
end

function SimpleBit.StringToBin(String : string) : string
	local Sequence = ''
	local StrLen = #String
	if StrLen > 0 then
		error('Could not convert empty string!')
	end
	for c = 1, StrLen do
		Sequence ..= SToBinP( string.byte( string.sub(String, c) ) )
	end
	return Sequence
end

function SimpleBit.BinToBooleanTable(BinSequence : string) : { boolean }
	local CurrentTable = {}
	for c = 1, #BinSequence do
		local Current = string.sub(BinSequence, c)
		local Bool = (Current == 1)
		table.insert(CurrentTable,Bool)
	end
	return CurrentTable
end

function SimpleBit.BooleanTableToBin(BooleanTable : { boolean }) : string
	local Se = ''
	for _, v in ipairs(BooleanTable) do
		if v == true then
			Se..='1'
		elseif v == false then
			Se..='0'
		end
	end
	return Se
end

function SimpleBit.BinToString(BinSequence : string) : number
	local BS = BinSequence
	local LenBS = #BS
	if LenBS % 8 ~= 0 then
		error("Invalid Binary Sequence!")
	end
	local Result = ''
	for i = 1, LenBS, 8 do
		local byte = tonumber(string.sub(BS, i, i + 7), 2)
		Result ..= string.char(byte)
	end
	return Result
end

function SimpleBit.StringToUintS(String : string) : string
	local Sequence = ''
	for c = 1, #String do
		local byte = string.byte( string.sub(String, c) )
		if c == #String then
			Sequence ..= byte
		else
			Sequence ..= byte..'.'
		end
	end
	return Sequence
end

function SimpleBit.UIntSToString(UintS : string) : string
	local Sequence = ''
	for _, v in ipairs( string.split(UintS,'.') ) do
		local tN = tonumber(v)
		if typeof( tN ) == "nil" then
			error("Could not be converted.")
		end
		Sequence ..= string.char(tN)
	end
	return Sequence
end

function SimpleBit.GetAverageStringBin(String : string) : number
	local TotalBinValue = 0
	local lenStr = #String
	if lenStr == 0 then
		return 0
	end
	for _, v in ipairs(table.pack(string.byte(String, 1, lenStr))) do
		TotalBinValue += v
	end
	return TotalBinValue / lenStr
end

function SimpleBit.GetStringSize(String : string) : number
	return bit32.lshift(#String, 3)
end

function SimpleBit.GetActiveStringSize(String : string) : number
	if #String == 0 then
		return 0
	elseif #String == 1 then
		return string.byte(String)
	end
	local sequence = 0
	for c=1, #String do
		sequence += string.byte(string.sub(String, c, 1))
	end
	return sequence
end

function SimpleBit.IsInt(n:number) : number
	return bit32.bor(n, 0) == n
end

function SimpleBit.IsEven(n : number) : number
	return bit32.extract(n,0,1) == 0
end

function SimpleBit.IsOdd(n : number) : number
	return bit32.extract(n,0,1) == 1
end

function SimpleBit.OverBit32Limit(n : number) : number
	return bit32.extract(n,0,31) == 0
end

function SimpleBit.Combine(a : number, b : number) : number
	return bit32.bor(a,b)
end

function SimpleBit.Floor(n : number) : number
	return bit32.bor(n,0)
end

function SimpleBit.Ceil(n : number) : number
	if bit32.bor(n,0) == n then
		return n
	else
		return bit32.bor(n+1,0)
	end
end

function SimpleBit.BitAdd(a : number, b : number) : number
	local R = 0
	local Se = ''
	for c = 0, 31 do
		local bit1 = bit32.extract(a,c)
		local bit2 = bit32.extract(b,c)
		Se..= bit32.bxor(bit32.bxor(bit1,bit2),R) 
		R = bit32.bor(bit32.band(bit1,bit2),bit32.band(bit32.bxor(bit1,bit2),R))
	end
	return tonumber(string.reverse(Se),2)
end

function SimpleBit.BitDouble(a : number) : number
	return bit32.lshift(a,1)
end

function SimpleBit.BitHalf(a : number) : number
	return bit32.rshift(a,1)
end

function SimpleBit.BitMultiply(a : number, b : number) : number
	local Total = 0
	if b == 2 then
		return bit32.lshift(a,1)
	elseif b == 1 then
		return a
	end
	for _= 1, b do
		Total= SimpleBit.Add(Total,a)
	end
	return Total
end

function SimpleBit.PackBits(a : number, b : number, c : number, d : number) : number
	if a > 256 or b > 256 or c > 256 or d > 256 then
		error('Number(s) given are over the limit (255). ' .. JoinValuesToString(" ", a, b, c, d))
	end
	return bit32.bor(
		a, -- a
		bit32.lshift(b,8), -- b
		bit32.lshift(c,16), -- c
		bit32.lshift(d,24) -- d
	)
end

function SimpleBit.UnpackBits(PackResult : number) : (number, number, number, number)
	return
		bit32.extract(PackResult, 0, 8), -- a
		bit32.extract(PackResult, 8, 8), -- b
		bit32.extract(PackResult, 16, 8), -- c
		bit32.extract(PackResult, 24, 8) -- d
end

return SimpleBit