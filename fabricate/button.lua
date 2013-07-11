local Tools = require "fabricate.tools"
tween = require "tween"

local button = {
}
button.__index = button


local capture
local buttons = {}

local function new(...)
	local b = {}
	setmetatable(b,button)

	b:init(...)
	b:register()
	return b
end

local function removeAll()
	buttons = {}
end

local function handlepress(_, x,y)
	if not capture then
		for i,b in ipairs(buttons) do
			if b.rect:contains(x,y) then
				capture = b
				return true
			end
		end
	end
end

local function handlerelease(_, x,y)
	if capture then
		if capture.rect:contains(x,y) then
			capture:pressed()
		end
		capture = nil
		return true
	end

end

local function handlekey(_,key)
	for i,b in ipairs(buttons) do
		if b.key == key then
			b:pressed()
		end
	end
end

function button:init(text,font,x,y,align,colors, key)
	--print(text, font, type(font))
	assert(font)
	self.text = text
	self.font = font
	self.align = align
	self.colors = colors
	self.key = key

	--get sizes
	local height = font:getHeight()
	local width = font:getWidth(text) + 1 -- without adding one, text in the result rect may wrap

	if align == "right" then
		self.rect = Tools:rect(x, x - width, y, y + height)
	elseif align == "left" then
		self.rect = Tools:rect(x, x + width, y, y + height)
	end

end

function button:unregister()
	if self.registered then
		for i,b in ipairs(buttons) do
			if b == self then
				table.remove(buttons, i)
				self.registered = false
				return
			end
		end
	end
end

function button:register()
	if not self.registered then	
	 	table.insert(buttons, self)
		self.registered = true
	end
end

function button:hovering()
	local mx, my = love.mouse.getPosition()

	if self.rect:contains(mx,my) then
		return true
	end
end

function button:pressed()
	if self.pressaction then
		self:pressaction()
	end
end

function button:update(dt)

end

function button:draw()
	local ishover = self:hovering()

	if ishover then
		love.graphics.setColor(self.colors.hover or self.colors.normal)
	else
		love.graphics.setColor(self.colors.normal)
	end
	love.graphics.setFont(self.font)

	local r = self.rect
	--r:draw("line")
	--love.graphics.scale(1 + scale)
	local cx, cy = r:center()
	local ox, oy = r:halfsize()
	love.graphics.print(self.text, math.floor(cx), math.floor(cy), 0, 1,1, math.floor(ox),math.floor(oy))--r.width, self.align)

end

local function draw()
	for i,b in ipairs(buttons) do
		b:draw()
	end
end

return setmetatable( {new = new, handlepress = handlepress, handlerelease=handlerelease, handlekey=handlekey, draw = draw}, {__call = function(_, ...) return new(...) end})