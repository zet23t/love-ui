local pico8api = require "love-ui.pico8api"

---@class text_component : ui_rect_component
---@field text string
---@field color integer
---@field align_x number
---@field align_y number
---@field t number
---@field r number
---@field b number
---@field l number
local text_component = require "love-util.class" "text_component":extends(require "love-ui.components.generic.ui_rect_component")

function text_component:new(text, color, t, r, b, l, align_x, align_y)
	return text_component:create {
		text = text or "", color = color or 7,
		l = l or 0, r = r or 0, t = t or 0, b = b or 0,
		align_x = align_x or 0.5,
		align_y = align_y or 0.5,
		rotation = 0
	}
end

function text_component:set_rotation(rotation)
	self.rotation = rotation or self.rotation
	return self
end

local function rotate(rotation, x0,y0, x, y, ...)
	local dx, dy = x - x0, y - y0
	local s, c = math.sin(rotation), math.cos(rotation)
	dx, dy = s * dy + c * dx, s * dx + c * dy
	if ... then
		return x0 + dx, y0 + dy, rotate(rotation, x0, y0, ...)
	end
	return x0 + dx, y0 + dy
end

function text_component:draw(ui_rect)
	local x0, y0 = ui_rect:to_world()
	local w = pico8api:text_width(self.text)
	local t, r, b, l = self.t, self.r, self.b, self.l
	local maxpos_x = ui_rect.w - r - l
	local maxpos_y = ui_rect.h - t - b
	local x = x0 + l + self.align_x * maxpos_x - w * self.align_x
	local y = y0 + t + self.align_y * maxpos_y - 12 * self.align_y + 1

	local min_x, min_y, max_x, max_y = x0 + l,
		y0 + t,
		x0 + ui_rect.w - r, y0 + ui_rect.h - b
	-- pico8api:rect(min_x, min_y, max_x, max_y,1)
	-- pico8api:rect(x, y, w + x, y + 16,1)
	-- pico8api:rect(x0, y0, ui_rect.w + x0, y0 + ui_rect.h,2)
	if self.rotation ~= 0 then
		x,y, min_x, min_y, max_x, max_y = rotate(self.rotation, x0, y0, x,y, min_x, min_y, max_x, max_y)
		-- min_x, min_y = rotate(self.rotation, x,y,x0,y0)
		-- pico8api:rect(x,y,max_x, max_y, 1)
		
	end
	pico8api:print(self.text, x, y, self.color, min_x, min_y, max_x, max_y, self.rotation)
end

function text_component:set_text(text)
	self.text = text or ""
end

return text_component
