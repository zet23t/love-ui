local pico8api = require "love-ui.pico8api"
local class = require "love-util.class"

---@class rectfill_component:ui_rect_component
---@field private create function
---@field fill integer
---@field border integer|nil
local rectfill_component = class "rectfill_component":extends(require "love-ui.components.generic.ui_rect_component")

---@param fill integer pico8 color id for filling
---@param border integer|nil pico8 color id for line, optional
---@return rectfill_component
function rectfill_component:new(fill, border)
	return self:create { fill = fill or -1, border = border or -1 }
end

function rectfill_component:draw(ui_rect)
	local x, y = ui_rect:to_world()
	local x2, y2 = x + ui_rect.w - 1, y + ui_rect.h - 1
	if self.fill >= 0 then pico8api:rectfill(x, y, x2 + 1, y2 + 1, self.fill, self.alpha) end
	if self.border >= 0 then pico8api:rect(x + .5, y + .5, x2 + .5, y2 + .5, self.border, self.alpha) end
end

function rectfill_component:set_alpha(alpha)
	self.alpha = alpha
	return self
end

return rectfill_component
