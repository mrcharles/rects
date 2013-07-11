tools = require "construct.tools"

local soundbank = {}
local streams = {}

local sounddata = {}

local sources = {}
local owners = {}

local sound = {}

local function loadStatic(path)
	local refs = path

	if type(refs) ~= "table" then
		refs = { refs }
	end

	local bank = {}
	for i,ref in ipairs(refs) do
		table.insert(bank,love.sound.newSoundData(ref))
	end
	
	return bank
end

function sound:loadTable(soundtable)
	if soundtable.static then
		for name,sound in pairs(soundtable.static) do
			if sound.path then
				soundbank[name] = loadStatic(sound.path)
			end
			assert(sound[name] == nil)
			sounddata[name] = tools:copy(sound)
			sounddata[name].data = "soundbank"
		end
	end
	if soundtable.stream then
		for name,sound in pairs(soundtable.stream) do
			if sound.path then
				print("loading streamed sound", name, sound.path)
				local src = love.audio.newSource(sound.path, "stream")
				
				src:setLooping(sound.loop or false)

				streams[name] = src
			end
			assert(sound[name] == nil)
			sounddata[name] = tools:copy(sound)
			sounddata[name].data = "stream"
		end
	end
end

function sound:play(name, owner)
	local s = sounddata[name]

	if not s then print("sound not found") return end

	if owner and owners[owner] then
		local data = owners[owner][name]

		if data and data.cooldown and data.cooldown > 0 then
			--print(name,"in cooldown")
			return
		end
	end

	if s.data == "soundbank" then 
		if soundbank[name] then
			local src = love.audio.newSource(soundbank[name][math.random(#soundbank[name])])
			table.insert(sources, src)
			love.audio.play(src)
			if s.volume then
				src:setVolume(s.volume)
			end
			if owner then
				local data = owners[owner] or {}
				--print(s.cooldown)
				data[name] = { cooldown = s.cooldown }

				owners[owner] = data
			end

		end
	else
		local src = streams[name]
		if src then
			love.audio.play(src)
		end
	end
end

--stop only valid on streams
function sound:stop(name)
	local s = sounddata[name]

	print("ok")
	if not s then return end

	print("wtf")
	if s.data == "stream" then
		print("STOPPING")
		streams[name]:stop()
	end
end

function sound:update(dt)
	local i = 1

	while i < #sources do
		if sources[i]:isStopped() then
			table.remove(sources, i)
		else
			i = i + 1
		end
	end

	for k,owner in pairs(owners) do
		for name, data in pairs(owner) do
			if data.cooldown then
				data.cooldown = data.cooldown - dt
				if data.cooldown <= 0 then
					data.cooldown = nil
				end
			end
		end
	end
end

return sound