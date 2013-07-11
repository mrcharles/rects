local Tools = require 'fabricate.tools'
local Map = Tools:Class()

function Map:init(w,h)
	self.width = w
	self.height = h

	if w and h then 
		self.x = 1
		self.y = 1
	else
		self.auto = true
	end

	self.data = {}
	return self
end

function Map:get(x,y)
	if self.data[y] then
		return self.data[y][x]
	end
end

function Map:set(x,y,v)
	local row = self.data[y] or {}
	row[x] = v
	self.data[y] = row
	if self.auto then
		if self.x == nil or x < self.x then
			self.x = x
		end
		if self.width == nil or x > self.width then
			self.width = x
		end
		if self.y == nil or y < self.y then
			self.y = y
		end
		if self.height == nil or y > self.height then
			self.height = y
		end
	end
end

function Map:iterateNeighbours4Way(x,y,iterator, validator)

	local dx,dy = x,y
	local v

	dx,dy = x + 1, y
	v = self:get(dx,dy)
	if v and (not validator or validator(dx,dy,v)) then
		iterator(dx,dy,v)
	end
	dx,dy = x - 1, y
	v = self:get(dx,dy)
	if v and (not validator or validator(dx,dy,v)) then
		iterator(dx,dy,v)
	end
	dx,dy = x, y + 1
	v = self:get(dx,dy)
	if v and (not validator or validator(dx,dy,v)) then
		iterator(dx,dy,v)
	end
	dx,dy = x, y - 1
	v = self:get(dx,dy)
	if v and (not validator or validator(dx,dy,v)) then
		iterator(dx,dy,v)
	end
end


function Map:iterateNeighbours8Way(x,y,iterator, validator)
	for y=y-1,y+1 do
		for x=x-1,x+1 do
			local v = self:get(x,y)
			if v and (not validator or validator(x,y,v)) then
				iterator(x,y,v)
			end
		end
	end
end

function Map:iterate(iterator, validator)
	for y=self.y,self.height do
		for x=self.x,self.width do
			local v = self:get(x,y)
			if not validator or validator(v) then
				if iterator(x,y,v) then
					return
				end
			end
		end
	end	
end

return Map