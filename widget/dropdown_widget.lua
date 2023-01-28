local text_component = require "love-ui.components.generic.text_component"
local sprite_component = require "love-ui.components.generic.sprite_component"

---@class dropdown_widget
local dropdown_widget = require "love-util.class" "dropdown_widget":extends(require "love-ui.components.generic.ui_rect_component")

---@param ui_theme ui_theme
---@param options string[]
---@return dropdown_widget
function dropdown_widget:new(ui_theme, options)
	return self:create {options = options}
end

return dropdown_widget
