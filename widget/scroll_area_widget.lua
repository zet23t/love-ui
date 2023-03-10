local ui_rect            = require "love-ui.ui_rect"
local rectfill_component = require "love-ui.components.generic.rectfill_component"
local scrollbar_widget   = require "love-ui.widget.scrollbar_widget"
local sprite_component   = require "love-ui.components.generic.sprite_component"
local clip_component     = require "love-ui.components.generic.clip_component"
local uitk_vars          = require "love-ui.uitk_vars"

---@class scroll_area_widget : ui_rect_component
---@field ui_theme ui_theme
---@field rect ui_rect
---@field scroll_content ui_rect
---@field scroll_bar_x ui_rect
---@field scroll_bar_y ui_rect
---@field scroll_bar_x_component scrollbar_widget
---@field scroll_bar_y_component scrollbar_widget
local scroll_area_widget = require "love-util.class" "scroll_area_widget":extends(require "love-ui.components.generic.ui_rect_component")

scroll_area_widget.mouse_wheel_factor = 15

function scroll_area_widget:new(ui_theme, content_width, content_height)
	local self = scroll_area_widget:create {
		ui_theme = ui_theme
	}
	self.scroll_content = ui_rect:new(0, 0, content_width or 400, content_height or 400)
	return self
end

function scroll_area_widget:init(rect)
	self.rect = rect
	self.diagonal_sash = ui_rect:new(0, 0, 16, 16, rect, rectfill_component:new(7),
		sprite_component:new(self.ui_theme.icon.diagonal_sash))
	self.scroll_area_view = ui_rect:new(0, 0, 0, 0, rect, self.ui_theme:scroll_area_view())
	self.scroll_area_view:add_component(clip_component:new(1, 1, 1, 1))
	self.scroll_bar_x = ui_rect:new(0, 0, 14, 14, rect)
	self.scroll_bar_y = ui_rect:new(0, 0, 14, 14, rect)
	self.scroll_bar_x_component = self.scroll_bar_x:add_component(scrollbar_widget:new_themed(1, self.ui_theme))
	self.scroll_bar_y_component = self.scroll_bar_y:add_component(scrollbar_widget:new_themed(2, self.ui_theme))
	self.scroll_content:set_parent(self.scroll_area_view)
end

function scroll_area_widget:is_mouse_over(rect)
	self.scroll_bar_x_component:set_pos(-uitk_vars.mouse_wheel_dx * self.mouse_wheel_factor +
		self.scroll_bar_x_component.pos)
	self.scroll_bar_y_component:set_pos(-uitk_vars.mouse_wheel_dy * self.mouse_wheel_factor +
		self.scroll_bar_y_component.pos)
end

function scroll_area_widget:set_position(x,y)
	self.scroll_bar_x_component:set_pos(x)
	self.scroll_bar_y_component:set_pos(y)
end

function scroll_area_widget:get_position()
	return self.scroll_bar_x_component.pos, self.scroll_bar_y_component.pos
end

function scroll_area_widget:increase_position(x,y)
	self.scroll_bar_x_component:set_pos(x + self.scroll_bar_x_component.pos)
	self.scroll_bar_y_component:set_pos(y + self.scroll_bar_y_component.pos)
end

function scroll_area_widget:layout_update(rect)
	local w, h = rect:get_size()
	local enabled_x = self.scroll_content.w > self.scroll_area_view.w
	local enabled_y = self.scroll_content.h > self.scroll_area_view.h
	self.scroll_bar_x:set_enabled(enabled_x)
	self.scroll_bar_y:set_enabled(enabled_y)
	self.diagonal_sash:set_enabled(enabled_x and enabled_y)

	if not enabled_x and not enabled_y then
		self.scroll_area_view.w = w
		self.scroll_area_view.h = h
		return
	end

	self.scroll_area_view.w = w - 7 * 2
	self.scroll_area_view.h = h - 7 * 2
	self.scroll_bar_x.y = h - 7 * 2
	self.scroll_bar_x.w = w - 7 * 2
	self.scroll_bar_y.x = w - 7 * 2
	self.scroll_bar_y.h = h - 7 * 2
	self.diagonal_sash.x = w - 8 * 2
	self.diagonal_sash.y = h - 8 * 2


	self.scroll_content.x = math.ceil(-self.scroll_bar_x_component.pos + 1) -- +1 to compensate clip_component
	self.scroll_content.y = math.ceil(-self.scroll_bar_y_component.pos + 1)
	self.scroll_bar_x_component.range = self.scroll_content.w
	self.scroll_bar_x_component.scope = self.scroll_area_view.w
	self.scroll_bar_y_component.range = self.scroll_content.h
	self.scroll_bar_y_component.scope = self.scroll_area_view.h
end

return scroll_area_widget
