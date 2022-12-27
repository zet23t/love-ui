local ui_theme = require "love-util.class" "ui_theme"

local sprite9_component = require "love-ui.components.generic.sprite9_component"
local text_component = require "love-ui.components.generic.text_component"

function ui_theme:new()
	return ui_theme:create()
end

function ui_theme:button_skin()
	local s9 = sprite9_component:new(16, 0, 8, 8, 2, 2, 2, 2);

	s9.mouse_enter = function(self)
		self.sx = 32
		self.is_dirty = true
	end

	s9.mouse_exit = function(self)
		self.sx = 16
		self.is_dirty = true
	end

	s9.is_pressed_down = function(self)
		self.sx = 24
		self.is_dirty = true
	end

	s9.was_released = function(self, rect)
		self.sx = rect.flags.is_mouse_over and 32 or 16
		self.is_dirty = true
	end

	return s9
end

function ui_theme:decorate_button_skin(ui_rect, caption, on_click)
	ui_rect:add_component(self:button_skin())
	if caption then
		ui_rect:add_component(text_component:new(caption, 1, 0, 0, 0, 0, .5, .5))
	end
	if on_click then
		ui_rect:add_component({
			was_released = function(self, rect)
				if rect.flags.is_mouse_over then
					on_click()
				end
			end
		})
	end
end

function ui_theme:window_skin()
	return sprite9_component:new(64, 0, 8, 16, 10, 3, 3, 3)
end

function ui_theme:decorate_window_skin(ui_rect, caption)
	ui_rect:add_component(self:window_skin())
	if caption then
		ui_rect:add_component(text_component:new(caption, 1, 1, 5, 0, 3, 0, 0))
	end
end

return ui_theme
