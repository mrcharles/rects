local tools = {}
tools.__index = tools

local rect = {}
rect.__index = rect

function rect:new(l,t,r,b)
	local r = {
		x = l,
		y = t,
		width = r - l,
		height = b - t,
	}
	--print("rect", r.x,r.width,r.y,r.height)
	setmetatable(r, rect)

	return r
end

function rect:draw(mode, border)
	love.graphics.rectangle(mode or "fill", self.x-border, self.y-border, self.width+border*2, self.height+border*2)
end

function rect:contains(x,y)
	if x >= self.x and x <= self.x + self.width 
		and y >= self.y and y <= self.y + self.height then
		return true
	end
end

function rect:center()
	return self.x + self.width/2, self.y + self.height/2
end

function rect:halfsize()
	return self.width/2, self.height/2
end

function tools:rect(x1,x2,y1,y2)
	--print("in",x1,x2,y1,y2)
	local l,t,r,b
	if x2 < x1 then
		l = x2
		r = x1
	else
		l = x1
		r = x2
	end

	if y2 < y1 then
		t = y2
		b = y1
	else
		t = y1
		b = y2
	end

	return rect:new(l,t,r,b)
end

function tools:arrayclone(t)
	local o = {}

	for i,v in ipairs(t) do
		o[i] = v
	end

	return o
end

function tools:copy(t)
	if type(t) == "table" then
		local o = {}
		for k,v in pairs(t) do
			o[k] = tools:copy(v)
		end
		return o
	else
		return t
	end
end

function tools:Class(super)
	local c = {}
	if super then
		super.__index = super
		setmetatable(c, super)
	end
	function c:new(...)
		return tools:makeClass(self,...)
	end	

	return c
end

function tools:makeClass(super, ...)
	local c = {}

	super.__index = super

	function super:isA(class)
		if class == super then
			return true
		end

		local parent = getmetatable(self) 
		while parent ~= nil do
			if parent == class then
				return true
			end
			parent = getmetatable(parent)
		end
	end
	
	setmetatable(c, super)

	assert( super.init ~= nil, "Cannot make a class out of a function without init()")

	local ret = c:init(...)
	assert(ret, "Construct.Tools:makeClass() - Init function must return an object.")
	return ret
end

function tools:wrap(val, range)
	-- if not (val <= 256 and val >= -1) then
	-- 	print('fuck')
	-- end

	if val > range then
		--print("wrapping",val,"to",val-range)	
		return val - range
	elseif val < 1 then
		--print("wrapping",val,"to",val+range)
		return val + range
	else
		return val
	end
end

function tools:HSVtoRGB(h,s,v)
	assert(h >= 0 and h < 360)
	assert(s >= 0 and s <= 1)
	assert(v >= 0 and v <= 1)

	--print("in",h,s,v)
	local C = s * v

	local H = h / 60

	local X = C * ( 1 - math.abs( (H % 2) - 1) )

	local r,g,b = tools:HXCtoRGB(H,X,C)

	local m = v - C

	return math.floor((r+m)*255),math.floor((g+m)*255),math.floor((b+m)*255)
end

function tools:HSLtoRGB(h,s,l)
	assert(h >= 0 and h < 360)
	assert(s >= 0 and s <= 1)
	assert(l >= 0 and l <= 1)

	local C = ( 1 - math.abs(2*l - 1)) * s

	local H = h / 60

	local X = C * ( 1 - math.abs( (H % 2) - 1) )

	local r,g,b = tools:HXCtoRGB(H,X,C)
	local m = l  - C/2

	return math.floor((r+m)*255),math.floor((g+m)*255),math.floor((b+m)*255)
end

function tools:HXCtoRGB(H,X,C)
	local r,g,b
	if H >= 0 and H < 1 then
		r,g,b = C,X,0
	elseif H >= 1 and H < 2 then
		r,g,b = X,C,0
	elseif H >= 2 and H < 3 then
		r,g,b = 0,C,X
	elseif H >= 3 and H < 4 then
		r,g,b = 0,X,C
	elseif H >= 4 and H < 5 then
		r,g,b = X,0,C
	elseif H >= 5 and H < 6 then
		r,g,b = C,0,X
	else
		assert(false, C,H,X)
	end
	return r,g,b
end

function tools:colorGenerator()
	local c = {360,1,0.5}
	local d = {30, {0.5,0.4,0.3,0.6,0.7}}
	local l = 1

	return function()
		local r = tools:copy(c)

		c[1] = c[1] - d[1]
		if c[1] < 0 then 
			c[1] = c[1] + 360
			l = l + 1
			if l > #(d[2]) then
				l = 1
			end
			c[3] = d[2][l]
		end
		--print(unpack(c))
		return {tools:HSLtoRGB(unpack(c))}
	end
end

function tools:dict(...)
	local d = { values = {} }

	for i,v in ipairs({...}) do
		d.values[v] = true
	end

	function d:has(val)
		return self.values[val]
	end

	return d
end

local images = {}

function tools:getImage(src)
	if images[src] == nil then
		images[src] = love.graphics.newImage(src)
		images[src]:setFilter("nearest","nearest")
	end

	return images[src]
end

function tools:shuffle(table,array)
-- To shuffle an array a of n elements (indices 0..n-1):
--   for i from n − 1 downto 1 do
--        j ← random integer with 0 ≤ j ≤ i
--        exchange a[j] and a[i]

	local out = (array and self:arrayclone(table)) or self:copy(table,depth)

	local size = #out
	for i=size,1,-1 do
		local j = math.random(size)
		local t = out[j]
		out[j] = out[i]
		out[i] = t
	end
	return out
end

return tools