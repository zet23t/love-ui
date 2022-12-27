local rect_contains = require "love-math.rect_contains"
local clamp = require "love-math.clamp"
local proxy_instance = require "love-util.proxy_instance"
local late_command = require "love-util.late_command"
local uitk_vars = require "love-ui.uitk_vars"
local pico8api = require "love-ui.pico8api"
local clip_stack = require "love-ui.clip_stack"
local uitk = require "love-ui.uitk"

local function trigger(cmps, name, ...)
	for i = 1, #cmps do
		local c = cmps[i]
		local f = c[name]
		if f then
			-- require "log" ("? %s:%s", c, name)
			f(c, ...)
		end
	end
	return trigger
end

local function queue_call(name, f, ...)
	local list = uitk_vars.queued_updates[name] or {}
	-- require "log" ("?qc %s %d",name, list and #list or -1)

	pico8api:add(list, { f = f, ... })
	uitk_vars.queued_updates[name] = list
end

local function flag_trigger(self, flag_name, mx, my)
	if self.flags[flag_name] then
		--require "log" ("?%s ",flag_name)
		queue_call(flag_name, trigger, self.components, flag_name, self, mx, my)
	end
	return flag_trigger
end

local function trigger_queued(cmps, name, ...)
	for i = 1, #cmps do
		local c = cmps[i]
		local f = c[name]
		if f and not c.disabled then
			queue_call(name, f, c, ...)
		end
	end
end

---@class ui_rect : object
---@field disabled boolean
---@field id string
---@field children ui_rect[]
---@field components ui_rect_component
---@field flags table
local ui_rect = require "love-util.class" "ui_rect"

function ui_rect:collect_hits(x, y, list)
	if self.disabled then
		return false
	end

	x = x - self.x
	y = y - self.y

	local is_inside = rect_contains(0, 0, self.w, self.h, x, y)
	if is_inside then
		pico8api:add(list, self, 1)
		list[self] = true
	end

	local has_handled = false
	for i = #self.children, 1, -1 do
		if self.children[i]:collect_hits(x, y, list) then
			has_handled = true
			break
		end
	end

	return is_inside or has_handled
end

function ui_rect:update_flags(mx, my, hits)
	if self.disabled then return end
	mx, my = mx - self.x, my - self.y
	local mouse_over = hits[self] and mx < self.w and my < self.h and mx >= 0 and my >= 0
	if mouse_over and #clip_stack > 0 then
		local wmx, wmy = uitk:get_mouse()
		local x1, y1 = self:to_world(0, 0)
		local x2, y2 = self.w + x1, self.h + y1
		local cx, cy, cw, ch = unpack(clip_stack[#clip_stack])
		x1, x2 = clamp(cx, cx + cw, x1, x2)
		y1, y2 = clamp(cy, cy + ch, y1, y2)
		mouse_over = rect_contains(x1, y1, x2, y2, wmx, wmy)
	end
	local flags = self.flags
	flags.is_top_hit = hits[1] == self
	flags.was_mouse_over = flags.is_mouse_over
	flags.is_mouse_over = mouse_over
	flags.was_released, flags.was_triggered, flags.was_pressed_down = false, false, false
	local was_mouse_over = flags.was_mouse_over
	--require "log" ("flagged %s = %s", "mouse_over",mouse_over and "true" or "false")
	if uitk_vars.was_mouse_pressed and mouse_over then
		flags.is_pressed_down = true
		flags.was_pressed_down = true
	end
	if uitk_vars.was_mouse_released and flags.is_pressed_down then
		flags.is_pressed_down = false
		flags.was_released = true
		if mouse_over then
			flags.was_triggered = true
		end
	end
	trigger(self.components, "pre_draw", self)(self.children, "update_flags", mx, my, hits)(self.components, "post_draw")
end

function ui_rect:recursive_trigger(name, ...)
	if self.disabled then return end
	trigger(self.components, name, self, ...)(self.children, "recursive_trigger", name, ...)
	return self
end

function ui_rect:root()
	return self.parent and self.parent:root() or self
end

function ui_rect:to_pos(n)
	if not self.parent then return end
	pico8api:del(self.parent.children, self)
	pico8api:add(self.parent.children, self, n)
end

function ui_rect:to_back()
	self:to_pos(1)
end

ui_rect.to_front = ui_rect.to_pos

function ui_rect:remove()
	late_command(function()
		if self.parent then
			pico8api:del(self.parent.children, self)
			self.parent = nil
		end
	end)
end

function ui_rect:update(mx, my)
	if self.disabled then return end
	mx, my = mx - self.x, my - self.y
	local flags = self.flags
	local mouse_over = flags.is_mouse_over
	local was_mouse_over = flags.was_mouse_over

	if mouse_over ~= was_mouse_over then
		trigger_queued(self.components, mouse_over and "mouse_enter" or "mouse_exit", mx, my)
	end

	flag_trigger(self, "is_mouse_over", mx, my)(
		self, "was_released", mx, my)(
		self, "was_pressed_down", mx, my)(
		self, "was_triggered", mx, my)(
		self, "is_pressed_down", mx, my)

	trigger_queued(self.components, "update", self, mx, my)
	trigger(self.children, "update", mx, my)
end

function ui_rect:draw()
	trigger(self.components, "pre_draw", self)(
		self.components, "draw", self)(
		self.children, "draw")(
		self.components, "post_draw", self)
end

function ui_rect:to_world(x, y)
	x, y = self.x + (x or 0), self.y + (y or 0)
	if self.parent then
		return self.parent:to_world(x, y)
	end
	return x, y
end

function ui_rect:add_component_proxy(cmp, ...)
	if cmp then
		return self:add_component(proxy_instance(cmp)), self:add_component_proxy(...)
	end
end

function ui_rect:get_size()
	return self.w, self.h
end

---Add a variable number of components to the ui_rect
---@param cmp ui_rect_component
---@param ... ui_rect_component
---@return ... ui_rect_component
function ui_rect:add_component(cmp, ...)
	if cmp then
		pico8api:add(self.components, cmp)
		if cmp.init then cmp:init(self) end
		return cmp, self:add_component(...)
	end
end

function ui_rect:get_component_by_id(id)
	for i = 1, #self.components do
		if self.components[i].id == id then
			return self.components[i]
		end
	end
end

function ui_rect:get_component_by_type(name)
	for i = 1, #self.components do
		if self.components[i].class_name == name then
			return self.components[i]
		end
	end
end

function ui_rect:foreach_component_method(method)
	local function search_subscribers(ui_rect)
		ui_rect = ui_rect or self
		for i = 1, #ui_rect.components do
			local component = ui_rect.components[i]
			if type(component[method]) == "function" then
				coroutine.yield(ui_rect, component)
			end
		end

		for i = 1, #ui_rect.children do
			search_subscribers(ui_rect.children[i])
		end
	end
	return coroutine.wrap(search_subscribers)
end

function ui_rect:get_child_by_id(id)
	require "log" ("%s.get_child_by_id(%s)", self.id, id)
	if self.id == id then
		return self
	end

	for i = 1, #self.children do
		local found = self.children[i]:get_child_by_id(id)
		if found then
			return found
		end
	end
end

function ui_rect:set_parent(p)
	self.parent = p
	pico8api:add(p.children, self)
end

function ui_rect:set_rect(x, y, w, h)
	self.x, self.y = x or self.x, y or self.y
	self.w, self.h = w or self.w, h or self.h
	return self
end

function ui_rect:new_with_proxy_components(x, y, w, h, parent, ...)
	local self = self:new(x, y, w, h, parent)
	self:add_component_proxy(...)
	return self
end

function ui_rect:set_enabled(is_enabled)
	self.disabled = not is_enabled
end

---@param x number
---@param y number
---@param w number
---@param h number
---@param parent ui_rect|nil
---@param ... table
---@return ui_rect
function ui_rect:new(x, y, w, h, parent, ...)
	local self = ui_rect:create {
		x = x, y = y, w = w, h = h,
		flags = {},
		components = {},
		children = {},
		id = "<>"
	}
	if parent then
		self:set_parent(parent)
	end
	self:add_component(...)
	return self
end

return ui_rect
