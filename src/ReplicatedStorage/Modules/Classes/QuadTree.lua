local Terrain = workspace.Terrain

local function SetProperties(Target, PropertyTable)
	if typeof(PropertyTable) == 'table' then
		for propName, propVal in pairs( PropertyTable ) do
			Target[propName] = propVal
		end
	end
	return Target
end

-- // Point // --
local Point = { ClassName = 'Point' }
Point.__index = Point

function Point.New(x, y)
	return setmetatable({x=x, y=y, _data=false}, Point)
end

function Point:Show( yLevel )
	yLevel = yLevel or 20
	local A = Instance.new('Attachment')
	A.Name = 'Point'
	A.WorldPosition = Vector3.new( self.x, yLevel, self.z )
	A.Visible = true
	A.Parent = Terrain
	return A
end

-- // Rectangle // --
local Rectangle = { ClassName = 'Rectangle' }
Rectangle.__index = Rectangle

function Rectangle.New(x, y, w, h)
	return setmetatable({
		x=x,
		y=y,
		w=w,
		h=h,
	}, Rectangle)
end

function Rectangle:Contains(point)
	local left = self.x - (self.w / 2)
	local right = self.x + (self.w / 2)
	local top = self.y - (self.h / 2)
	local bottom = self.y + (self.h / 2)
	return (
		left <= point.x and
		point.x <= right and
		top <= point.y and
		point.y <= bottom
	)
end

function Rectangle:Intersects(range)
	local left = self.x - (self.w / 2)
	local right = self.x + (self.w / 2)
	local top = self.y - (self.h / 2)
	local bottom = self.y + (self.h / 2)

	local rangeleft = range.x - (range.w / 2)
	local rangeright = range.x + (range.w / 2)
	local rangetop = range.y - (range.h / 2)
	local rangebottom = range.y + (range.h / 2)
	return not (
		right < rangeleft or
		rangeright < left or
		bottom < rangetop or
		rangebottom < top
	)
end

function Rectangle:Show( yLevel )
	yLevel = yLevel or 20

	local corners = {
		Vector3.new(self.x + self.w/2, yLevel, self.y + self.h/2),
		Vector3.new(self.x - self.w/2, yLevel, self.y + self.h/2),
		Vector3.new(self.x - self.w/2, yLevel, self.y - self.h/2),
		Vector3.new(self.x + self.w/2, yLevel, self.y - self.h/2),
	}

	local visualizeInstances = {}
	for i, v in ipairs(corners) do
		local A = Instance.new('Attachment')
		A.Name = 'C'..i
		A.WorldPosition = v
		A.Visible = true
		A.Parent = Terrain
		table.insert(visualizeInstances, A)
	end

	local _col = ColorSequence.new(Color3.new(1,1,1))
	local lastAttachment = visualizeInstances[#visualizeInstances]
	for _, attachment in ipairs(visualizeInstances) do
		if lastAttachment then
			local b = Instance.new('Beam')
			b.Color = self.customColor or _col
			b.FaceCamera = true
			b.Attachment0 = attachment
			b.Attachment1 = lastAttachment
			b.LightEmission = 1
			b.LightInfluence = 0
			b.Width0 = 0.5
			b.Width1 = 0.5
			b.Parent = attachment
		end
		lastAttachment = attachment
	end

	return visualizeInstances
end

-- // Quad Tree // --
local DEFAULT_QUAD_TREE_CAPACITY = 4

local QuadTree = { ClassName = 'QuadTree' }
QuadTree.__index = QuadTree

function QuadTree.New(Properties)
	return setmetatable(SetProperties({
		boundary = Rectangle.New(0,0,1,1),
		capacity = DEFAULT_QUAD_TREE_CAPACITY,
		points = {},

		_divided = false,
		_northeast = nil,
		_northwest = nil,
		_southeast = nil,
		_southwest = nil,
	}, Properties), QuadTree)
end

function QuadTree:_Subdivide()
	local x = self.boundary.x
	local y = self.boundary.y
	local w = self.boundary.w
	local h = self.boundary.h

	self._northeast = QuadTree.New({
		boundary = Rectangle.New({
			x = x + w/4,
			y = y - h/4,
			w = w/2,
			h = h/2,
		}),
		capacity = self.capacity,
	})

	self._northwest = QuadTree.New({
		boundary = Rectangle.New({
			x = x - w/4,
			y = y - h/4,
			w = w/2,
			h = h/2,
		}),
		capacity = self.capacity,
	})

	self._southeast = QuadTree.New({
		boundary = Rectangle.New({
			x = x + w/4,
			y = y + h/4,
			w = w/2,
			h = h/2,
		}),
		capacity = self.capacity,
	})

	self._southwest = QuadTree.New({
		boundary = Rectangle.New({
			x = x - w/4,
			y = y + h/4,
			w = w/2,
			h = h/2,
		}),
		capacity = self.capacity,
	})

	self._divided = true
end

function QuadTree:Insert(...)
	self:InsertArray({...})
end

function QuadTree:InsertArray(array)
	for _, shape in ipairs(array) do
		if not self.boundary:Contains( shape ) then
			continue
		end

		if #self.points < self.capacity then
			table.insert(self.points, shape)
			continue
		end

		if not self._divided then
			self:_Subdivide()
		end

		if self._northeast:Insert(shape) then
		elseif self._northwest:Insert(shape) then
		elseif self._southeast:Insert(shape) then
		elseif self._southwest:Insert(shape) then
		end
	end
end

function QuadTree:Query( _range, point_array )
	point_array = point_array or { }
	if _range:Intersects(self.boundary) then
		for _, p in ipairs(self.points) do
			if (p.ClassName == 'Point' and _range:Contains(p)) or (p.ClassName == 'Rectangle' and _range:Intersects(p)) then
				if not table.find(point_array, p) then
					table.insert(point_array, p)
				end
			end
		end
		if self._divided then
			self._northwest:Query(_range, point_array)
			self._northeast:Query(_range, point_array)
			self._southwest:Query(_range, point_array)
			self._southeast:Query(_range, point_array)
		end
	end
	return point_array
end

function QuadTree:Show( yLevel )
	yLevel = yLevel or 20

	local visualizeInstances = self.boundary:Show(yLevel)
	for i, point in ipairs(self.points) do
		local att = Instance.new('Attachment')
		att.WorldPosition = Vector3.new( point.x, yLevel, point.y )
		att.Name = 'P:'..i
		att.Visible = true
		att.Parent = Terrain
		table.insert(visualizeInstances, att)
	end

	if self._divided then
		local points = self.northeast:Show(yLevel)
		table.move(points, 1, #points, #visualizeInstances + 1, visualizeInstances)
		points = self.northwest:Show(yLevel)
		table.move(points, 1, #points, #visualizeInstances + 1, visualizeInstances)
		points = self.southeast:Show(yLevel)
		table.move(points, 1, #points, #visualizeInstances + 1, visualizeInstances)
		points = self.southwest:Show(yLevel)
		table.move(points, 1, #points, #visualizeInstances + 1, visualizeInstances)
	end

	return visualizeInstances
end

return {Rectangle = Rectangle, Point = Point, QuadTree = QuadTree}
