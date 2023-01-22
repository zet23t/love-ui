local pico8api = require "love-ui.pico8api"
local uitk_vars = require "love-ui.uitk_vars"
local clamp = require "love-math.clamp"

---@class textfield_component : ui_rect_component
---@field text string
---@field color integer
---@field align_x number
---@field align_y number
---@field t number
---@field r number
---@field b number
---@field l number
---@field caret_position integer
local textfield_component = require "love-util.class" "textfield_component":extends(require "love-ui.components.generic.ui_rect_component")

function textfield_component:new(text, color, t, r, b, l, align_x, align_y)
	return textfield_component:create {
		text = text or "", color = color or 7,
		l = l or 0, r = r or 0, t = t or 0, b = b or 0,
		align_x = align_x or 0.5,
		align_y = align_y or 0.5,
		caret_position = 0
	}
end

function textfield_component:is_text_valid(text)
	return true
end

function textfield_component:on_text_updated()
end

function textfield_component:on_focus_lost()
end

function textfield_component:mouse_enter()
	self.has_focus = true
end

function textfield_component:mouse_exit()
	self.has_focus = false
	self:on_focus_lost()
end

function textfield_component:was_triggered(rect, mx, my)
	self.caret_position = self:local_to_text_index(rect, mx, my)
end

function textfield_component:text_index_to_local(rect, text_position)
	local w = pico8api:text_width(self.text)
	local t, r, b, l = self.t, self.r, self.b, self.l
	local maxpos_x = rect.w - r - l
	local maxpos_y = rect.h - t - b

	local offset = pico8api:text_width(self.text:sub(1, text_position))

	return l + self.align_x * maxpos_x - w * self.align_x + offset,
		t + self.align_y * maxpos_y - 12 * self.align_y + 1
end

function textfield_component:local_to_text_index(rect, lx, ly)
	local sx = self:text_index_to_local(rect, 0)
	local tx = lx - sx
	for i = 1, #self.text do
		if tx < 4 then return i - 1 end
		tx = tx - pico8api:text_width(self.text:sub(i, i))
	end
	return #self.text
end

function textfield_component:set_caret_position(pos)
	self.caret_position = clamp(0, #self.text, pos)
end

function textfield_component:update(rect)
	if not self.has_focus then return end
	if uitk_vars.last_key_pressed == "left" then
		self:set_caret_position(self.caret_position - 1)
	elseif uitk_vars.last_key_pressed == "right" then
		self:set_caret_position(self.caret_position + 1)
	elseif uitk_vars.last_key_pressed == "backspace" and self.caret_position > 0 then
		self.text = self.text:sub(1, self.caret_position - 1) .. self.text:sub(self.caret_position + 1)
		self.caret_position = self.caret_position - 1
		self:on_text_updated()
	elseif uitk_vars.last_text_input then
		local new_text = self.text:sub(1, self.caret_position) ..
			uitk_vars.last_text_input .. self.text:sub(self.caret_position + 1)
		if self:is_text_valid(new_text) then
			self.text = new_text
			self.caret_position = self.caret_position + 1
			self:on_text_updated()
		end
	end
end

function textfield_component:draw(rect)
	local x, y = rect:to_world()
	local lx, ly = self:text_index_to_local(rect, 0)
	x, y = x + lx, y + ly

	pico8api:print(self.text, x, y, self.color)
	if self.has_focus and math.floor(love.timer.getTime() / .3) % 2 == 1 then
		local cx, cy = rect:to_world(self:text_index_to_local(rect, self.caret_position))
		pico8api:rectfill(cx - 2, cy - 2, cx + 2, cy + 12, self.color)
	end
end

function textfield_component:set_text(text)
	self.text = text or ""
end

return textfield_component
