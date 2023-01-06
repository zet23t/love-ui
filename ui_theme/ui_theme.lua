local rectfill_component = require "love-ui.components.generic.rectfill_component"
local sprite9_component = require "love-ui.components.generic.sprite9_component"
local sprite_component = require "love-ui.components.generic.sprite_component"
local text_component = require "love-ui.components.generic.text_component"

---@class ui_theme : object
local ui_theme = require "love-util.class" "ui_theme"

ui_theme.icon = {
	cursor = 1;
	open_folder = 5;
	save_disk = 6;
	close_x = 7;
	toggle_not_set = 10;
	toggle_set = 11;
	send_up = 15;
	home = 16;
	cursor_resize = 17;
	move = 18;
	rotate = 19;
	vertice_add = 20;
	vertice_remove = 21;
	fill = 22;
	diagonal_sash = 23;
	selection = 25;
	undo = 26;
	redo = 27;
	select_all = 28;
	select_none = 29;
	select_invert = 30;
	send_down = 31;
	scale = 32;
	tiny_triangle_left = 33;
	tiny_triangle_right = 34;
	tiny_triangle_up = 35;
	tiny_triangle_down = 36;
	play = 37;
	pause = 38;
	to_end = 39;
	hierarchy = 41;
	closed_folder = 42;
	generic_file = 43;
}

function ui_theme:new()
	return ui_theme:create()
end

function ui_theme:scrollbar_shaft_skin()
	local s9 = sprite9_component:new(72, 0, 8, 8, 2, 2, 2, 2)
	return s9
end

function ui_theme:scroll_area_view()
	return rectfill_component:new(7,1)
end

function ui_theme:scrollbar_slider_skin()
	local s9 = sprite9_component:new(16, 0, 8, 8, 2, 2, 2, 2)
	return s9
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
		ui_rect:add_component{ was_triggered = on_click }
	end
end

function ui_theme:decorate_on_click(ui_rect, on_click)
	ui_rect:add_component({
		was_released = function(self, rect)
			if rect.flags.is_mouse_over then
				on_click()
			end
		end
	})
end

function ui_theme:decorate_sprite(ui_rect, icon_id)
	ui_rect:add_component(sprite_component:new(icon_id))
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
