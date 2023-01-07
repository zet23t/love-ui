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
		align_y = align_y or 0.5
	}
end

function text_component:draw(ui_rect)
	local x, y = ui_rect:to_world()
	local w = pico8api:text_width(self.text)
	local t, r, b, l = self.t, self.r, self.b, self.l
	local maxpos_x = ui_rect.w - r - l
	local maxpos_y = ui_rect.h - t - b
	x = x + l + self.align_x * maxpos_x - w * self.align_x
	y = y + t + self.align_y * maxpos_y - 12 * self.align_y + 1

	pico8api:print(self.text, x, y, self.color)
end

function text_component:set_text(text)
	self.text = text or ""
end

return text_component
