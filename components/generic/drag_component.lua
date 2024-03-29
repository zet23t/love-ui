---@class drag_component : ui_rect_component
---@field dragged_rect ui_rect|nil if set, this is the rect that's dragged. Otherwise the component will drag its own rect
---@field raster number A raster value to use when positioning the dragged element
local drag_component = require "love-util.class" "drag_component":extends(require "love-ui.components.generic.ui_rect_component")

local function donothing() end

---@param dragged_rect ui_rect|nil the ui_rect to drag; if nil, the component will move its own rect
---@param raster number|nil the raster to use to align the rect. Defaults to 1.
---@return unknown
function drag_component:new(dragged_rect, raster, on_position_updated, on_begin, on_finished)
	return drag_component:create {
		dragged_rect = dragged_rect;
		raster = raster or 1;
		on_position_updated = on_position_updated;
		on_begin = on_begin;
		on_finished = on_finished;
	}
end

function drag_component:on_position_updated(rect, x, y)
end

function drag_component:is_pressed_down(rect, mx, my)
	rect = self.dragged_rect or rect
	local px,py = rect.x, rect.y
	local rx = math.floor((rect.x + mx - self.mx) / self.raster + .5) * self.raster
	local ry = math.floor((rect.y + my - self.my) / self.raster + .5) * self.raster
	local x,y = self:on_position_updated(rect, rx, ry)
	rect.x = x or rx
	rect.y = y or ry
	local dx,dy = rect.x - px, rect.y - py
	self.distance = self.distance + (dx*dx+dy*dy)^.5
end

function drag_component:was_released()
	if self.on_finished and self.distance > 0 then
		self:on_finished()
	end
end

function drag_component:was_pressed_down(ui_rect, mx, my)
	if ui_rect.flags.is_top_hit then
		self.mx, self.my = mx, my
		self.distance = 0
		if self.on_begin then
			self:on_begin()
		end
		
		self.is_pressed_down = nil
	else
		self.is_pressed_down = donothing
	end
end

return drag_component
