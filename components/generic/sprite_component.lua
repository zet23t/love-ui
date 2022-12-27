local pico8api = require "love-ui.pico8api"

---@class sprite_component:ui_rect_component
local sprite_component = require "love-util.class" "sprite_component":extends(require "love-ui.components.generic.ui_rect_component")

---@param sprite_id integer
---@param x number|nil
---@param y number|nil
---@param w number|nil
---@param h number|nil
---@return sprite_component
function sprite_component:new(sprite_id, x, y, w, h)
	return sprite_component:create {
		sprite_id = tonumber(sprite_id) or 0,
		x = x or 0, y = y or 0,
		w = w or 1, h = h or 1
	}
end

function sprite_component:draw(ui_rect)
	local x, y = ui_rect:to_world(self.x, self.y)
	pico8api:spr(self.sprite_id, x, y, self.w, self.h)
end

return sprite_component