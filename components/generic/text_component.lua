local pico8api = require "love-ui.pico8api"
local pico8_colors = require "lib.love-ui.pico8_colors"

---@class text_component : ui_rect_component
---@field text string
---@field color integer
---@field align_x number
---@field align_y number
---@field font love.Font
---@field t number
---@field r number
---@field b number
---@field l number
local text_component = require "love-util.class" "text_component":extends(require "love-ui.components.generic.ui_rect_component")
text_component.line_height = 12
text_component.line_spacing = 4
text_component.newline_indent = 0
text_component.firstline_indent = 0
text_component.scale = 1

function text_component:new(text, color, t, r, b, l, align_x, align_y)
	return text_component:create {
		text = text or "", color = color or 7,
		l = l or 0, r = r or 0, t = t or 0, b = b or 0,
		align_x = align_x or 0.5,
		align_y = align_y or 0.5,
		rotation = 0
	}
end

function text_component:set_newline_indent(x)
	self.newline_indent = x
	return self
end

function text_component:set_firstline_indent(x)
	self.firstline_indent = x
	return self
end

function text_component:set_multiline(enabled)
	self.is_multiline_enabled = enabled
	return self
end

function text_component:set_line_height(line_height)
	self.line_height = line_height
	return self
end

function text_component:set_line_spacing(line_spacing)
	self.line_spacing = line_spacing
	if self.font and line_spacing ~= 0 then
		print "warning: line spacing + font is not implemented"
	end
	return self
end

local function get_wrapped_text(self, text, max_width)
	local lines = {}
	for text_line_start, text_line, line_break in text:gmatch "()([^\n]*)\n?" do
		local line = ""
		local line_width = self.firstline_indent
		local start_pos = text_line_start - 1
		for fragment_start, fragment, word in text_line:gmatch "()(%s*(%S+))" do
			local width = self:get_width(fragment)
			if (line_width + width > max_width) and (line_width > 0) then
				lines[#lines + 1] = { line, line_width, start_pos }
				line = word
				line_width = self:get_width(line) + self.newline_indent
				start_pos = start_pos + fragment_start
			else
				line_width = line_width + width
				line = line .. fragment
			end
		end
		if #line > 0 then
			lines[#lines + 1] = { line, line_width, start_pos }
		end
	end
	return lines
end

---@param self text_component
local function layout_update_size(self, rect)
	local lines
	if self.is_fitting_width then
		lines = get_wrapped_text(self, self.text, self.wrapping_width)
		local max_width = 0
		for i = 1, #lines do
			max_width = math.max(max_width, lines[i][2])
		end
		rect.w = max_width + self.r + self.l
	end

	if not self.is_fitting_height then
		return
	end

	if self.cached_text == self.text and self.cached_w == rect.w and self.cached_h == rect.h then
		return
	end

	local maxpos_x = rect.w - self.r - self.l
	lines = lines or get_wrapped_text(self, self.text, maxpos_x)
	rect.h = (self.line_height * #lines + self.line_spacing * (#lines - 1)) * self.scale + self.b + self.t
	if self.font then
		rect.h = rect.h - (self.font:getHeight() - self.font:getBaseline()) * self.scale
	end
	self.cached_text = self.text
	self.cached_w = rect.w
	self.cached_h = rect.h
end

function text_component:set_formatting_table(tab)
	self.formatting = tab
	return self
end

function text_component:set_fitting_height(enabled)
	self.is_fitting_height = enabled
	self.layout_update_size = (self.is_fitting_height or self.is_fitting_width) and layout_update_size
	return self
end

function text_component:set_fitting_width(enabled, wrapping_width)
	self.is_fitting_width = enabled
	self.wrapping_width = wrapping_width or 1000
	self.layout_update_size = (self.is_fitting_height or self.is_fitting_width) and layout_update_size
	return self
end

---@param font love.Font
function text_component:set_font(font)
	self.font = font
	if font then
		self.line_height = font:getHeight()
		self.line_spacing = 0
	end
	return self
end

function text_component:set_rotation(rotation)
	self.rotation = rotation or self.rotation
	return self
end

local function rotate(rotation, x0, y0, x, y, ...)
	local dx, dy = x - x0, y - y0
	local s, c = math.sin(rotation), math.cos(rotation)
	dx, dy = s * dy + c * dx, s * dx + c * dy
	if ... then
		return x0 + dx, y0 + dy, rotate(rotation, x0, y0, ...)
	end
	return x0 + dx, y0 + dy
end

function text_component:set_scale(scale)
	self.scale = scale
	return self
end

function text_component:get_width(text)
	return (self.font and self.font:getWidth(text) or pico8api:text_width(text)) * self.scale
end

function text_component:draw(ui_rect)
	local t, r, b, l = self.t, self.r, self.b, self.l
	local x0, y0 = ui_rect:to_world()
	local w = self:get_width(self.text)
	local h = ui_rect.h -- self.line_height * self.scale
	local maxpos_x = ui_rect.w - r - l
	local maxpos_y = ui_rect.h - t - b
	local scale = self.scale

	if self.font then
		love.graphics.setFont(self.font)
		love.graphics.setColor(unpack(pico8_colors[self.color]))
		-- love.graphics.rectangle("line",x0,y0,ui_rect.w, ui_rect.h)
	end

	local cursive = 0
	local function print_with_formatting(text, x, y, rotation, scale, start_pos, formatting)
		local p = 1
		for i = 1, #formatting do
			local fmt = formatting[i]
			local to = fmt.pos - start_pos
			if to > #text then
				break
			end
			if to > 1 then
				local part = text:sub(p, to)
				p = to + 1
				-- start_pos = fmt.pos
				-- lim_log(i,#formatting,"'" .. part .. "'", fmt.pos, start_pos)
				love.graphics.print(part, x, y, rotation, scale, scale, 0, 0, cursive, 0)
				if fmt.attribute == "cursive" then
					cursive = fmt.value and -0.25 or 0
					if fmt.value then
						x = x + self:get_width(" ")
					else
						x = x - self:get_width " "
					end
				end
				x = x + self:get_width(part)
			end
		end

		if p <= #text then
			love.graphics.print(text:sub(p), x, y, rotation, scale, scale, 0, 0, cursive, 0)
		end
	end

	local function print_line(text, w, xoff, yoff, start_pos)
		local x = x0 + l + self.align_x * maxpos_x - w * self.align_x
		local y = y0 + t + self.align_y * maxpos_y - h * self.align_y + 1

		local min_x, min_y, max_x, max_y = x0 + l,
			y0 + t,
			x0 + ui_rect.w - r, y0 + ui_rect.h - b
		-- pico8api:rect(min_x, min_y, max_x, max_y,1)
		-- pico8api:rect(x, y, w + x, y + 16,1)
		-- pico8api:rect(x0, y0, ui_rect.w + x0, y0 + ui_rect.h,2)
		if self.rotation ~= 0 then
			x, y, min_x, min_y, max_x, max_y = rotate(self.rotation, x0, y0, x, y, min_x, min_y, max_x, max_y)
			-- min_x, min_y = rotate(self.rotation, x,y,x0,y0)
			-- pico8api:rect(x,y,max_x, max_y, 1)
		end
		-- pico8api:rect(min_x, min_y, max_x, max_y, 1)
		if self.font then
			if self.formatting and #self.formatting > 0 then
				print_with_formatting(text, x + xoff, y + yoff, self.rotation, scale, start_pos, self.formatting)
			else
				love.graphics.print(text, x + xoff, y + yoff, self.rotation, scale, scale, 0, 0, 0, 0)
			end
		else
			pico8api:print(text, x + xoff, y + yoff, self.color, min_x, min_y, max_x, max_y, self.rotation)
		end
	end

	if w > maxpos_x and self.is_multiline_enabled then
		local lines = get_wrapped_text(self, self.text, maxpos_x)
		local line_offset = (self.line_height + self.line_spacing) * scale
		h = self.line_height * #lines * scale + self.line_spacing * (#lines - 1) * scale
		for i, line in ipairs(lines) do
			local indent = i > 1 and self.newline_indent or self.firstline_indent
			print_line(line[1], line[2], indent, (i - 1) * line_offset, line[3])
		end
	else
		print_line(self.text, w, self.firstline_indent, 0, 0)
	end

	if self.font then
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function text_component:set_text(text)
	self.text = text or ""
end

return text_component
