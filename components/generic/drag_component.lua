---@class drag_component : ui_rect_component
---@field dragged_rect ui_rect|nil if set, this is the rect that's dragged. Otherwise the component will drag its own rect
---@field raster number A raster value to use when positioning the dragged element
local drag_component = require "love-util.class" "drag_component":extends(require "love-ui.components.generic.ui_rect_component")

local function donothing() end

---@param dragged_rect ui_rect|nil the ui_rect to drag; if nil, the component will move its own rect
---@param raster number|nil the raster to use to align the rect. Defaults to 1.
---@return unknown
function drag_component:new(dragged_rect, raster)
	return drag_component:create {
		dragged_rect = dragged_rect;
		raster = raster or 1;
	}
end

function drag_component:on_position_updated(rect, x, y)
end

function drag_component:is_pressed_down(rect, mx, my)
	rect = self.dragged_rect or rect
	rect.x = math.floor((rect.x + mx - self.mx) / self.raster + .5) * self.raster
	rect.y = math.floor((rect.y + my - self.my) / self.raster + .5) * self.raster
	self:on_position_updated(rect, rect.x, rect.y)
end

function drag_component:was_pressed_down(ui_rect, mx, my)
	if ui_rect.flags.is_top_hit then
		self.mx, self.my = mx, my
		self.is_pressed_down = nil
	else
		self.is_pressed_down = donothing
	end
end

return drag_component
