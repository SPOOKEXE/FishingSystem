local TweenService = game:GetService('TweenService')

-- // Moduke // --
local Module = {}

local baseButton = Instance.new('ImageButton')
baseButton.Name = 'Button'
baseButton.AnchorPoint = Vector2.new(0.5, 0.5)
baseButton.Position = UDim2.fromScale(0.5, 0.5)
baseButton.Size = UDim2.fromScale(1, 1)
baseButton.BackgroundTransparency = 1
baseButton.Selectable = true
baseButton.ImageTransparency = 1
baseButton.ZIndex = 50
function Module:CreateActionButton(properties)
	local button = baseButton:Clone()
	if typeof(properties) == 'table' then
		for k, v in pairs(properties) do
			button[k] = v
		end
	end
	return button
end

local activeHovers = {}
local linearTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
function Module:CreateHoverEffect(Object)
	if activeHovers[Object] then
		return
	end
	activeHovers[Object] = true

	local UIScale = Object:FindFirstChildOfClass('UIScale')
	if not UIScale then
		UIScale = Instance.new('UIScale')
		UIScale.Name = 'UIScale'
		UIScale.Parent = Object
	end

	local initialScale = UIScale.Scale
	Object.MouseEnter:Connect(function()
		TweenService:Create(UIScale, linearTweenInfo, {Scale = initialScale * 1.1}):Play()
	end)
	Object.MouseLeave:Connect(function()
		TweenService:Create(UIScale, linearTweenInfo, {Scale = initialScale}):Play()
	end)
end

return Module