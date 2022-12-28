local max = math.max
local clamp = require "love-math.clamp"
local func_list = require "love-util.func_list"
local late_command = require "love-util.late_command"
local gstore_accessor = require "love-util.gstore_accessor"
local sprite_component= require "love-ui.components.generic.sprite_component"

---@class scrollbar_widget:ui_rect_component
---@field axis 1|2
---@field shaft_skin_component ui_rect_component
---@field slider_skin_component ui_rect_component
---@field button_skin_component ui_rect_component
---@field icon_less_component ui_rect_component
---@field icon_more_component ui_rect_component
---@field range number
---@field scope number
---@field pos number
---@field value_change_listeners func_list
local scrollbar_widget = require "love-util.class" "scrollbar_widget":extends(require "love-ui.components.generic.ui_rect_component")

---@param axis 1|2 
---@param shaft_skin_component ui_rect_component
---@param slider_skin_component ui_rect_component
---@param button_skin_component ui_rect_component
---@param icon_less_component ui_rect_component
---@param icon_more_component ui_rect_component
---@return scrollbar_widget
function scrollbar_widget:new(axis, shaft_skin_component, slider_skin_component, button_skin_component, icon_less_component, icon_more_component)
	return scrollbar_widget:create {
		axis = axis or 1,
		shaft_skin_component = shaft_skin_component or {},
		slider_skin_component = slider_skin_component or {},
		button_skin_component = button_skin_component or {},
		icon_less_component = icon_less_component or {},
		icon_more_component = icon_more_component or {},
		range = 100,
		scope = 20,
		pos = 0,
		value_change_listeners = func_list:new()
	}
end

---@param axis 1|2
---@param ui_theme ui_theme
function scrollbar_widget:new_themed(axis, ui_theme)
	return self:new(axis, ui_theme:scrollbar_shaft_skin(), ui_theme:scrollbar_slider_skin(), ui_theme:button_skin(), 
		sprite_component:new(axis == 1 and ui_theme.icon.tiny_triangle_left or ui_theme.icon.tiny_triangle_down),
		sprite_component:new(axis == 1 and ui_theme.icon.tiny_triangle_right or ui_theme.icon.tiny_triangle_up)
	)
end

gstore_accessor(scrollbar_widget, "pos")

function scrollbar_widget:add_listener(f)
	self.value_change_listeners:add(f)
	return self
end

function scrollbar_widget:remove_listener(f)
	self.value_change_listeners:remove(f)
	return self
end

function scrollbar_widget:init(ui_rect)
	ui_rect:add_component_proxy(self.shaft_skin_component)

	self.less_rect = ui_rect:new_with_proxy_components(0, 0, 0, 0, ui_rect,
		self.button_skin_component, self.icon_less_component)
	self.more_rect = ui_rect:new_with_proxy_components(0, 0, 0, 0, ui_rect,
		self.button_skin_component, self.icon_more_component)
	self.slider_rect = ui_rect:new_with_proxy_components(0, 0, 0, 0, ui_rect,
		self.slider_skin_component)

	self.slider_rect:add_component({
		was_pressed_down = function(cmp, ui_rect, mx, my)
			self.dragging = true
			self.drag_x, self.drag_y = mx, my
		end,
		was_released = function(self) self.dragging = false end,
		is_pressed_down = function(cmp, slider_ui_rect, mx, my)
			local dx, dy = mx - self.drag_x, my - self.drag_y
			local d = self.axis == 1 and dx or dy

			local w, h = ui_rect.w, ui_rect.h
			local horizontal = self.axis == 1
			local available_size = horizontal and (w - h * 2) or (h - 2 * w)
			local slider_size = max(horizontal and h or w, self.scope / self.range * available_size)
			local wiggle_room = available_size - slider_size
			local position = self:get_pos(0) / (self.range - self.scope) * wiggle_room

			local next_position = position + d
			local next_pos = (self.range - self.scope) * next_position / wiggle_room
			next_pos = clamp(0, self.range - self.scope, next_pos)
			if next_pos ~= self:get_pos(0) then
				late_command:queue(function() self.value_change_listeners:invoke(self, self:get_pos(0), self:get_pos(0) - next_pos) end)
				self:set_pos(next_pos)
			end
		end
	})
end

function scrollbar_widget:layout_update(ui_rect)
	local w, h = ui_rect.w, ui_rect.h
	local horizontal = self.axis == 1
	local available_size = horizontal and (w - h * 2) or (h - 2 * w)
	local slider_size = max(horizontal and h or w, self.scope / self.range * available_size)
	local wiggle_room = available_size - slider_size
	local position = self:get_pos(0) / (self.range - self.scope) * wiggle_room
	
	if self.axis == 1 then
		self.less_rect:set_rect(0, 0, h, h)
		self.more_rect:set_rect(w - h, 0, h, h)
		self.slider_rect:set_rect(h + position, 0, slider_size, h)
	else
		self.less_rect:set_rect(0, 0, w, w)
		self.more_rect:set_rect(0, h - w, w, w)
		self.slider_rect:set_rect(0, w + position, w, slider_size)
	end
end

return scrollbar_widget