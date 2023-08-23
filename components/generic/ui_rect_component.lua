---@class ui_rect_component : object
---@field disabled boolean|nil if true, the component is ignored; using disabled instead of enabled because disabled = false for empty tables
local ui_rect_component = require "love-util.class" "ui_rect_component"

function ui_rect_component:set_enabled(is_enabled)
	self.disabled = not is_enabled
end

return ui_rect_component