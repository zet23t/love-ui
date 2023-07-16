local pico8api = require "love-ui.pico8api"
local class = require "love-util.class"

---@class rectfill_component:ui_rect_component
---@field private create function
---@field fill integer
---@field border integer|nil
local rectfill_component = class "rectfill_component":extends(require "love-ui.components.generic.ui_rect_component")
rectfill_component.border_width = 1
rectfill_component.l = 0
rectfill_component.r = 0
rectfill_component.b = 0
rectfill_component.t = 0

---@param fill integer|nil pico8 color id for filling
---@param border integer|nil pico8 color id for line, optional
---@param alpha number|nil alpha to use when drawing border and fill
---@return rectfill_component
function rectfill_component:new(fill, border, alpha)
	return self:create { fill = fill or -1, border = border or -1, alpha = alpha }
end

function rectfill_component:set_padding(t, r, b, l)
	self.l = l
	self.r = r
	self.b = b
	self.t = t
	return self
end

function rectfill_component:draw(ui_rect)
	local x, y = ui_rect:to_world()
	local x2, y2 = x + ui_rect.w - 1 - self.r, y + ui_rect.h - 1 - self.b
	x, y = x + self.l, y + self.t

	if type(self.fill) == "table" or self.fill >= 0 then pico8api:rectfill(x, y, x2 + 1, y2 + 1, self.fill, self.alpha) end
	if self.border >= 0 then
		for i = 0, self.border_width - 1 do
			pico8api:rect(x + .5 + i, y + .5 + i, x2 + .5 - i, y2 + .5 - i, self.border, self.alpha)
		end
	end
end

function rectfill_component:set_alpha(alpha)
	self.alpha = alpha
	return self
end

function rectfill_component:set_fill(fill)
	self.fill = fill or -1
	return self
end

function rectfill_component:set_border(border)
	self.border = border or -1
	return self
end

function rectfill_component:set_border_width(w)
	self.border_width = w
	return self
end

return rectfill_component
