local Tools = require "fabricate.tools"
local Camera = require "hump.camera"

local horiz = {}
local vert = {}
local side = {}

local width = 10
local border = 3

local backcolor = {220,220,220}
local forecolor = {50,50,50}

local size = 20

local len = size * ( width + border ) + border 

local camera

function drawHorizBar(y)
	local x = 0
	love.graphics.setColor(backcolor)
	love.graphics.rectangle("fill", x + border, y * (width+border), len - border * 2, width + border * 2)
	love.graphics.setColor(forecolor)
	love.graphics.rectangle("fill", x + border, y * (width+border) + border, len - border * 2, width)
end

function drawVertBar(x)
	local y = 0
	love.graphics.setColor(backcolor)
	love.graphics.rectangle("fill", x * (width+border), y + border, width + border * 2, len - border * 2)
	love.graphics.setColor(forecolor)
	love.graphics.rectangle("fill", x * (width+border) + border, y + border, width, len - border * 2)
end

function love.load()
	camera = Camera( border + len / 2, border + len / 2, 1, math.pi / 4)
	love.graphics.setBackgroundColor(backcolor)
	love.graphics.setLineStyle("smooth")

	for i=1,size do
		table.insert(horiz, i)
		table.insert(vert, i)
		table.insert(side, "h")
		table.insert(side, "v")
	end
	horiz = Tools:shuffle(horiz, true)
	vert = Tools:shuffle(vert, true)
	side = Tools:shuffle(side, true)
end

function love.draw()

	camera:attach()
	local x = 1
	local y = 1

	for i=1,size * 2 do
		if side[i] == "v" then
			drawVertBar(assert(vert[x]-1))
			x = x + 1
		else
			drawHorizBar(assert(horiz[y]-1))
			y = y + 1
		end
	end
	camera:detach()
end