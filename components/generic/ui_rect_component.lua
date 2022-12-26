---@class ui_rect_component

local ui_rect_component = require "love-util.class" "ui_rect_component"

function ui_rect_component:set_enabled(is_enabled)
	self.disabled = not is_enabled
end

return ui_rect_component