local pico8api = require "love-ui.pico8api"

---@class sprite9_component : ui_rect_component
---@field batch love.SpriteBatch
local sprite9_component = require "love-util.class" "sprite9_component":extends(require "love-ui.components.generic.ui_rect_component")
function sprite9_component:new(sx, sy, sw, sh, t, r, b, l, sheet)
	sheet = assert(sheet or pico8api.sprite_sheet)
	local c = sprite9_component:create {
		is_dirty = true,
		sx = sx or 0, sy = sy or 0, sw = sw or 0, sh = sh or 0,
		t = t or 0, r = r or 0, b = b or 0, l = l or 0,
		batch = love.graphics.newSpriteBatch(sheet, 9, "dynamic"),
		sheet_w = sheet:getWidth(),
		sheet_h = sheet:getHeight(),
	}
	return c
end

function sprite9_component:draw(ui_rect)
	if not self.is_dirty or not self.quads or self.quads ~= self then
		self.is_dirty = true
	end
	if self.is_dirty then
		local sx, sy, sw, sh, t, r, b, l = self.sx, self.sy, self.sw, self.sh, self.t, self.r, self.b, self.l
		local x1, x2, x3 = sx, sx + l, sx + sw - r
		local y1, y2, y3 = sy, sy + t, sy + sh - b
		local w1, w2, w3 = l, sw - l - r, r
		local h1, h2, h3 = t, sh - t - b, b

		local quads = {owner = self}
		local sheet_size_w = self.sheet_w
		local sheet_size_h = self.sheet_h
		quads[1] = love.graphics.newQuad(x1, y1, w1, h1, sheet_size_w, sheet_size_h)
		quads[2] = love.graphics.newQuad(x2, y1, w2, h1, sheet_size_w, sheet_size_h)
		quads[3] = love.graphics.newQuad(x3, y1, w3, h1, sheet_size_w, sheet_size_h)
		quads[4] = love.graphics.newQuad(x1, y2, w1, h2, sheet_size_w, sheet_size_h)
		quads[5] = love.graphics.newQuad(x2, y2, w2, h2, sheet_size_w, sheet_size_h)
		quads[6] = love.graphics.newQuad(x3, y2, w3, h2, sheet_size_w, sheet_size_h)
		quads[7] = love.graphics.newQuad(x1, y3, w1, h3, sheet_size_w, sheet_size_h)
		quads[8] = love.graphics.newQuad(x2, y3, w2, h3, sheet_size_w, sheet_size_h)
		quads[9] = love.graphics.newQuad(x3, y3, w3, h3, sheet_size_w, sheet_size_h)
		self.quads = quads
	end
	local x, y = ui_rect:to_world()
	local w, h = ui_rect.w, ui_rect.h
	---@type love.SpriteBatch
	local batch = self.batch
	if w ~= self.batched_w or h ~= self.batched_h or self.is_dirty then
		self.batched_w = w
		self.batched_h = h
		local sw, sh = self.sw, self.sh
		local t, r, b, l = self.t, self.r, self.b, self.l

		local x1, x2, x3 = 0, l, w - r
		local y1, y2, y3 = 0, t, h - b
		local w1, w2, w3 = 1, (w - l - r) / (sw - l - r), 1
		local h1, h2, h3 = 1, (h - t - b) / (sh - t - b), 1
		batch:clear()
		batch:add(self.quads[1], x1, y1, 0, w1, h1)
		batch:add(self.quads[2], x2, y1, 0, w2, h1)
		batch:add(self.quads[3], x3, y1, 0, w3, h1)
		batch:add(self.quads[4], x1, y2, 0, w1, h2)
		batch:add(self.quads[5], x2, y2, 0, w2, h2)
		batch:add(self.quads[6], x3, y2, 0, w3, h2)
		batch:add(self.quads[7], x1, y3, 0, w1, h3)
		batch:add(self.quads[8], x2, y3, 0, w2, h3)
		batch:add(self.quads[9], x3, y3, 0, w3, h3)
	end

	self.is_dirty = false

	love.graphics.draw(batch, x, y)
end

return sprite9_component
