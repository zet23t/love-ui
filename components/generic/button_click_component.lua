local class = require "love-util.class"

---@class rectfill_component:ui_rect_component
local button_click_component = class "rectfill_component":extends(require "love-ui.components.generic.ui_rect_component")

function button_click_component:new(on_click)
	return self:create { on_click = on_click }
end

function button_click_component:on_click(rect)
end

function button_click_component:was_released(rect)
	if rect.flags.is_mouse_over then
		self:on_click(rect)
	end
end

return button_click_component
