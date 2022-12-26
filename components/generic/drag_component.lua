local drag_component = require "love-util.class" "drag_component":extends(require "love-ui.components.generic.ui_rect_component")

local function donothing() end

function drag_component:new()
	return drag_component:create {}
end

function drag_component:is_pressed_down(ui_rect, mx, my)
	ui_rect.x = ui_rect.x + mx - self.mx
	ui_rect.y = ui_rect.y + my - self.my
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