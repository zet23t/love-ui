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
	output = 44;
	input = 45;
	cursor_horizontal = 49;
}

function ui_theme:new()
	return ui_theme:create()
end

function ui_theme:scrollbar_shaft_skin()
	local s9 = sprite9_component:new(72 * 2, 0, 16, 16, 4, 4, 4, 4)
	return s9
end

function ui_theme:scroll_area_view()
	return rectfill_component:new(7, 1)
end

function ui_theme:scrollbar_slider_skin()
	local s9 = sprite9_component:new(16 * 2, 0, 16, 16, 4, 4, 4, 4)
	return s9
end

function ui_theme:button_skin()
	local s9 = sprite9_component:new(16 * 2, 0, 16, 16, 4, 4, 4, 4);

	s9.mouse_enter = function(self)
		self.sx = 32 * 2
		self.is_dirty = true
	end

	s9.mouse_exit = function(self)
		self.sx = 16 * 2
		self.is_dirty = true
	end

	s9.is_pressed_down = function(self)
		self.sx = 24 * 2
		self.is_dirty = true
	end

	s9.was_released = function(self, rect)
		self.sx = rect.flags.is_mouse_over and 32 * 2 or 16 * 2
		self.is_dirty = true
	end

	return s9
end

function ui_theme:decorate_button_skin(ui_rect, caption, sprite, on_click)
	ui_rect:add_component(self:button_skin())
	if caption then
		ui_rect:add_component(text_component:new(caption, 1, 0, 0, 0, 0, .5, .5))
	end
	if type(sprite) == "function" then
		on_click = sprite
	elseif sprite then
		ui_rect:add_component(sprite_component:new(sprite, 2, 2))
	end
	if on_click then
		ui_rect:add_component { was_triggered = on_click }
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

function ui_theme:panel_skin()
	return sprite9_component:new(0, 48, 16, 32, 18, 6, 6, 6)
end

function ui_theme:decorate_panel_skin(ui_rect, caption)
	ui_rect:add_component(self:panel_skin())
	if caption then
		ui_rect:add_component(text_component:new(caption, 1, 2, 0, 0, 0, 0.5, 0))
	end
end

function ui_theme:window_skin()
	return sprite9_component:new(64 * 2, 0, 8 * 2, 16 * 2, 10 * 2, 3 * 2, 3 * 2, 3 * 2)
end

function ui_theme:decorate_window_skin(ui_rect, caption)
	ui_rect:add_component(self:window_skin())
	if caption then
		ui_rect:add_component(text_component:new(caption, 1, 2, 10, 0, 6, 0, 0))
	end
end

function ui_theme:decorate_toggle_skin(ui_rect, caption, state, on_toggle)
	local sprite = ui_rect:add_component(sprite_component:new(state and self.icon.toggle_set or self.icon.toggle_not_set, 0, (ui_rect.h - 16) / 2))
	ui_rect:add_component(text_component:new(caption or "", 1, 2, 0, 0, 20, 0))
	ui_rect:add_component({
		was_released = function(_, rect)
			state = not state
			sprite:set_sprite(state and self.icon.toggle_set or self.icon.toggle_not_set)
			if rect.flags.is_mouse_over and on_toggle then
				on_toggle(state)
			end
		end
	})
end

return ui_theme
