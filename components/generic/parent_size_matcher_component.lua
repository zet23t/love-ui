---@class parent_size_matcher_component
---@field t number|true
---@field r number|true
---@field b number|true
---@field l number|true

local parent_size_matcher_component = require "love-util.class" "parent_size_matcher_component":extends(require "love-ui.components.generic.ui_rect_component")

---Top, right, bottom, left distances relative to parent component size. If values passed are "true"
---the current width / height of the ui_rect is used and the rect is not expanded. If all values
---passed are "true", this component does essentially nothing.
---@param t number|true
---@param r number|true
---@param b number|true
---@param l number|true
---@return parent_size_matcher_component
function parent_size_matcher_component:new(t, r, b, l)
	return parent_size_matcher_component:create { t = t or 0, r = r or 0, b = b or 0, l = l or 0 }
end

function parent_size_matcher_component:layout_update(ui_rect)
	local l, t, b, r = self.l, self.t, self.b, self.r
	local pw, ph = ui_rect.parent.w, ui_rect.parent.h
	if t == true and b == true then
		t = ui_rect.y
		b = ph - t - ui_rect.h
	elseif t == true then
		t = ph - b - ui_rect.h
	elseif b == true then
		b = ph - t - ui_rect.h
	end

	if l == true and r == true then
		l = ui_rect.x
		r = pw - l - ui_rect.w
	elseif l == true then
		l = pw - r - ui_rect.w
	elseif r == true then
		r = pw - l - ui_rect.w
	end

	local x, y = l, t
	local w, h = pw - r - l, ph - b - t

	ui_rect:set_rect(x, y, w, h)
end

return parent_size_matcher_component
