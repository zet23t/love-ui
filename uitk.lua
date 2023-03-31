local floor = require "love-math.floor"
local pico8api = require "love-ui.pico8api"
local uitk_vars = require "love-ui.uitk_vars"

local cursor_normal = { id = 1, offset_x = -1, offset_y = -1 }
local cursor_resize = { id = 17, offset_x = -4, offset_y = -4 }
local cursor_horizontal = { id = 49, offset_x = -8, offset_y = -8 }
local cursor_hidden = { id = -1 }
local cursor = cursor_normal

local uitk = {
	cursors = {
		cursor_normal = cursor_normal;
		cursor_resize = cursor_resize;
		cursor_hidden = cursor_hidden;
		cursor_horizontal = cursor_horizontal;
	}
}
uitk._mt = { __index = uitk }

function uitk:new()
	local self = setmetatable({}, self._mt)
	self.context = {
		was_mouse_pressed = false,
		was_mouse_dragged = false,
		was_mouse_released = false,
		queued_updates = {},
		frame_counter = 0,
	}
	self.context_mt = { __index = self.context, __newindex = self.context }
	return self
end

function uitk:load_context()
	setmetatable(uitk_vars, self.context_mt)
	--print("loaded: ",uitk_vars.was_mouse_released,uitk_vars.was_mouse_released,self.context.was_mouse_pressed)
end

function uitk:set_cursor(c)
	cursor = c
end

function uitk:keypressed(key)
	self:load_context()
	uitk_vars.last_key_pressed = key
end
function uitk:textinput(key)
	self:load_context()
	uitk_vars.last_text_input = key
end

function uitk:draw(root)
	self:load_context()
	uitk_vars.frame_counter = uitk_vars.frame_counter + 1
	local x, y = uitk:get_mouse()
	root:recursive_trigger("layout_update_size")
		:recursive_trigger("layout_update")
		:draw()
	pico8api:clip()
	if cursor.id >= 0 then
		pico8api:spr(cursor.id, x + cursor.offset_x, y + cursor.offset_y)
	end
end

local function call_all(name)
	local list = uitk_vars.queued_updates[name]
	if list then
		for i = 1, #list do
			list[i].f(unpack(list[i]))
		end
	end
	return call_all
end

local prev_mouse_down, mouse_down
function uitk:update(root)
	self:load_context()
	local x, y, b = uitk:get_mouse()
	mouse_down = b
	uitk_vars.was_mouse_pressed = mouse_down and not prev_mouse_down
	uitk_vars.was_mouse_released = not mouse_down and prev_mouse_down
	if uitk_vars.was_mouse_pressed then
		uitk_vars.mouse_press_start_x = x
		uitk_vars.mouse_press_start_y = y
		uitk_vars.mouse_was_dragged = false
	end
	if mouse_down and not uitk_vars.mouse_was_dragged then
		local dx, dy = uitk_vars.mouse_press_start_x - x, uitk_vars.mouse_press_start_y - y
		uitk_vars.mouse_was_dragged = dx*dx+dy*dy > 9
	end
	-- print("??",mouse_down,uitk_vars.was_mouse_pressed)
	local hits = {}
	root:do_layout():collect_hits(x, y, hits)
	root:update_flags(x, y, hits)
	
	uitk_vars.queued_updates = {}
	-- the update call is collecting information which calls need to be done
	root:update(x, y)
	
	-- it is important to execute all callbacks orderly one by one after another
	call_all
	"mouse_exit" "mouse_enter"
	"is_mouse_over"
	
	if uitk_vars.was_mouse_pressed and #hits > 0 then
		uitk_vars.dragged_element = hits[1]
		local mx,my = uitk_vars.dragged_element:to_local(x,y)
		uitk_vars.dragged_element:trigger_on_components("has_drag_started", uitk_vars.dragged_element, mx, my, b)
	end
	if uitk_vars.dragged_element then
		local mx,my = uitk_vars.dragged_element:to_local(x,y)
		uitk_vars.dragged_element:trigger_on_components("is_dragged", uitk_vars.dragged_element, mx, my, b)
		if uitk_vars.was_mouse_released and uitk_vars.dragged_element then
			uitk_vars.dragged_element:trigger_on_components("has_drag_ended", uitk_vars.dragged_element, mx, my, b)
			uitk_vars.was_mouse_released = nil
		end
	end
	

	call_all
	"was_released" "was_pressed_down" "was_triggered"
	"is_pressed_down"
	"update"
	
	prev_mouse_down = mouse_down
	uitk_vars.mouse_wheel_dx = 0
	uitk_vars.mouse_wheel_dy = 0
	uitk_vars.previous_mouse_x = uitk_vars.mouse_x or 0
	uitk_vars.previous_mouse_y = uitk_vars.mouse_y or 0
	uitk_vars.mouse_x = x
	uitk_vars.mouse_y = y
	uitk_vars.mouse_dx = x - uitk_vars.previous_mouse_x
	uitk_vars.mouse_dy = y - uitk_vars.previous_mouse_y

	if uitk_vars.was_mouse_released then
		uitk_vars.mouse_press_start_x = nil
		uitk_vars.mouse_press_start_y = nil
		uitk_vars.mouse_was_dragged = false
	end

	uitk_vars.last_key_pressed = nil
	uitk_vars.last_text_input = nil
end

function uitk:mouse_wheelmoved(dx, dy)
	uitk_vars.mouse_wheel_dx = dx
	uitk_vars.mouse_wheel_dy = dy
end

function uitk:enable_mouse()

	--poke(0x5f2d, 1)
end

--- return x,y and if mouse button is pressed (only one mouse button)
---@return number mouse x
---@return number mouse y
---@return boolean true if primary pressed
function uitk:get_mouse(return_floating)
	local x, y = love.mouse.getPosition()
	x, y = love.graphics.inverseTransformPoint(x, y)
	if not return_floating then x, y = floor(x + .5, y + .5) end
	return x, y, love.mouse.isDown(1)
end

return uitk
