local floor = require "love-math.floor"
local pico8api = require "love-ui.pico8api"
local uitk_vars = require "love-ui.uitk_vars"

local cursor_normal = { id = 1, offset_x = -1, offset_y = -1 }
local cursor_resize = { id = 17, offset_x = -4, offset_y = -4 }
local cursor = cursor_normal

local uitk = {}
uitk._mt = { __index = uitk }

function uitk:new()
	local self = setmetatable({}, self._mt)
	self.context = {
		was_mouse_pressed = false,
		was_mouse_released = false,
		queued_updates = {},
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

function uitk:draw(root)
	self:load_context()
	local x, y = uitk:get_mouse()
	root:recursive_trigger("layout_update_size")
		:recursive_trigger("layout_update")
		:draw()
	pico8api:clip()
	pico8api:spr(cursor.id, x + cursor.offset_x, y + cursor.offset_y)
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
	-- print("??",mouse_down,uitk_vars.was_mouse_pressed)
	local hits = {}
	root:do_layout()
		:collect_hits(x, y, hits)
	root:update_flags(x, y, hits)

	uitk_vars.queued_updates = {}
	-- the update call is collecting information which calls need to be done
	root:update(x, y)

	-- it is important to execute all callbacks orderly one by one after another
	call_all
	"mouse_exit" "mouse_enter"
	"is_mouse_over"
	"was_released" "was_pressed_down" "was_triggered"
	"is_pressed_down"
	"update"

	prev_mouse_down = mouse_down
	uitk_vars.mouse_wheel_dx = 0
	uitk_vars.mouse_wheel_dy = 0
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
function uitk:get_mouse()
	local x, y = love.mouse.getPosition()
	x, y = floor(love.graphics.inverseTransformPoint(x, y))
	return x, y, love.mouse.isDown(1)
end

return uitk
