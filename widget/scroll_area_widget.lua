local ui_rect                       = require "love-ui.ui_rect"
local parent_size_matcher_component = require "love-ui.components.layout.parent_size_matcher_component"

---@class scroll_area_widget : object
---@field ui_rect ui_rect
local scroll_area_widget = require "love-util.class" "scroll_area_widget"

function scroll_area_widget:new(x,y,w,h,parent_rect,ui_theme)
	local widget = self:create()
	widget.ui_rect = ui_rect:new(x,y,w,h,parent_rect)
	return widget
end

function scroll_area_widget:set_parent(ui_rect)
	self.ui_rect:set_parent(ui_rect)
end

return scroll_area_widget