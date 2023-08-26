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
	panel = 46;
	import = 47;
	export = 63;
	cursor_horizontal = 49;
	burger_menu = 50;
	star_filled = 51;
	star_outline = 52;
	big_blue_x = 53;
	big_blue_dash = 54;
	play_reverse = 55;
	to_start = 56;
	locked_mouse = 57;
	locked_lock = 58;
	unlocked_lock = 59;
	eye_open = 60;
	eye_closed = 61;
	limited_play = 62;
	looped_play = 66;
	pen = 67;
	eraser = 68;
	move_arrows = 69;
	hand = 70;
	grid = 71;
	boundary_paint = 72;
	open_folder_add = 73;
	triangle_up = 75;
	triangle_down = 74;
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

function ui_theme:push_button_skin(state)
	local s9 = sprite9_component:new(16 * 2, 0, 16, 16, 4, 4, 4, 4);
	--self.push_button_state = state

	s9.set_push_button_state = function(self, state)
		self.push_button_state = state
		self:was_released()
	end


	s9.mouse_enter = function(self)
		self.sx = self.push_button_state and 48 or 64
		self.mouse_is_over = true
		self.is_dirty = true
	end

	s9.was_triggered = function(self, rect)
		self.push_button_state = not self.push_button_state
		self:was_released()
	end

	s9.mouse_exit = function(self)
		self.sx = self.push_button_state and 144 or 32
		self.mouse_is_over = false
		self.is_dirty = true
	end

	s9.is_pressed_down = function(self)
		self.sx = self.push_button_skin and 64 or 48
		self.is_dirty = true
	end

	s9.was_released = function(self)
		if self.mouse_is_over then
			self.sx = self.push_button_state and 48 or 64
		else
			self.sx = self.push_button_state and 144 or 32
		end
		self.is_dirty = true
	end

	s9:set_push_button_state(state)


	return s9
end

---@param ui_rect ui_rect
---@param caption string|nil
---@param sprite integer|nil
---@param on_click function|nil
---@return ui_rect
function ui_theme:decorate_button_skin(ui_rect, caption, sprite, on_click)
	ui_rect:add_component(self:button_skin())
	local has_sprite = type(sprite) == "number"
	if caption then
		ui_rect:add_component(text_component:new(caption, 1, 2, 6, 2, has_sprite and 19 or 6, has_sprite and 0 or .5, .5))
	end
	if type(sprite) == "function" then
		on_click = sprite
	elseif sprite then
		ui_rect:add_component(sprite_component:new(sprite, 
			caption and 2 or math.floor((ui_rect.w - 16) / 2), math.floor((ui_rect.h-16) /2)))
	end
	if on_click then
		ui_rect:add_component { was_triggered = on_click }
	end
	return ui_rect
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

function ui_theme:rounded_panel_skin()
	return sprite9_component:new(16, 64, 16, 16, 6, 6, 6, 6)
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

---@param ui_rect ui_rect
---@param caption any
---@return ui_rect
function ui_theme:decorate_window_skin(ui_rect, caption)
	ui_rect:add_component(self:window_skin())
	if caption then
		ui_rect:add_component(text_component:new(caption, 1, 2, 10, 0, 6, 0, 0))
	end
	return ui_rect
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

function ui_theme:decorate_push_button_skin(ui_rect,state, caption, sprite, on_toggle)
	local skin = ui_rect:add_component(self:push_button_skin(state))
	local has_sprite = type(sprite) == "number"
	if caption then
		ui_rect:add_component(text_component:new(caption, 1, 2, 6, 2, has_sprite and 19 or 6, has_sprite and 0 or .5, .5))
	end
	if type(sprite) == "function" then
		on_toggle = sprite
	elseif sprite then
		ui_rect:add_component(sprite_component:new(sprite, 
			caption and 2 or math.floor((ui_rect.w - 16) / 2), math.floor((ui_rect.h-16) /2)))
	end
	if on_toggle then
		ui_rect:add_component { was_triggered = function() 
			on_toggle(skin.push_button_state)
		end}
	end
	return ui_rect
end

return ui_theme
