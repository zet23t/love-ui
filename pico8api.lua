local floor = require "love-math.floor"
local pico8api = {}
pico8api.colors = require "love-ui.pico8_colors"
pico8api.sheet_size = 256
pico8api.icon_size = 16

local function with_color(fn, r, g, b, a)
	local r0, g0, b0, a0 = love.graphics.getColor()
	love.graphics.setColor(r, g, b, a)
	fn()
	love.graphics.setColor(r0, g0, b0, a0)
end

function pico8api:rectfill(x, y, x2, y2, color, alpha_override)
	local r, g, b, a = unpack(self.colors[color])
	with_color(function()
		love.graphics.rectangle("fill", x, y, x2 - x, y2 - y)
	end, r, g, b, alpha_override or a)
end

function pico8api:screen_size()
	local w, h = love.graphics.getDimensions()
	local ax, ay = love.graphics.transformPoint(1, 0)
	local bx, by = love.graphics.transformPoint(0, 0)
	local dx, dy = ax - bx, ay - by
	local len = (dx * dx + dy * dy) ^ .5
	return w / len, h / len
end

---@param sprite_sheet string file to use as sprite sheet
function pico8api:load(sprite_sheet, font_sheet)
	self.sprite_sheet = love.graphics.newImage(sprite_sheet)
	self.font_sheet = love.graphics.newImage(font_sheet)
	self.quads = {}
	for i = 0, 127 do
		self.quads[i] = love.graphics.newQuad(i % 16 * self.icon_size, math.floor(i / 16) * self.icon_size, self.icon_size, self.icon_size, self.sheet_size, self.sheet_size)
	end
	self.text_batch = love.graphics.newSpriteBatch(self.font_sheet, 1000, "dynamic")
end

function pico8api:print(text, x, y, color)
	local r0, g0, b0, a0 = love.graphics.getColor()
	love.graphics.setColor(unpack(self.colors[color or 0]))

	self.text_batch:clear()
	local tx = 0
	for i = 1, #text do
		local id = string.byte(text, i)
		self.text_batch:add(self.quads[id], tx, 0)
		tx = tx + (id < 128 and self.icon_size/2 or self.icon_size)
	end
	love.graphics.draw(self.text_batch, floor(x, y))

	love.graphics.setColor(r0, g0, b0, a0)
end

function pico8api:text_width(s)
	local w = 0
	for i = 1, #s do
		if string.byte(s, i) >= 128 then
			w = w + self.icon_size
		else
			w = w + self.icon_size / 2
		end
	end
	return w - 1
end

function pico8api:rect(x, y, x2, y2, color, alpha_override)
	local r, g, b, a = unpack(self.colors[color])
	with_color(function()
		love.graphics.rectangle("line", x, y, x2 - x, y2 - y)
	end, r, g, b, alpha_override or a)
end

function pico8api:spr(id, x, y, w, h)
	love.graphics.draw(self.sprite_sheet, self.quads[id], math.floor(x), math.floor(y))
end

function pico8api:deli(t, i)
	return table.remove(t, i)
end

function pico8api:clip(x, y, w, h)
	if x then
		x, y = love.graphics.transformPoint(x, y)
		local ox, oy = love.graphics.transformPoint(0, 0)
		w, h = love.graphics.transformPoint(w, h)
		w, h = w - ox, h - oy
		love.graphics.setScissor(x, y, math.max(0, w), math.max(0, h))
	else
		love.graphics.setScissor()
	end
end

function pico8api:add(t, v, i)
	if i then
		table.insert(t, i, v)
	else
		table.insert(t, v)
	end
end

function pico8api:del(t, v)
	for i = 1, #t do
		if t[i] == v then
			table.remove(t, i)
			return v
		end
	end
end

return pico8api
