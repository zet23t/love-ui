---@class vertical_layouter_component : ui_rect_component
local vertical_layouter_component = require "love-util.class" "vertical_layouter_component":extends(require "love-ui.components.generic.ui_rect_component")

function vertical_layouter_component:new(donot_update_size, t, r, b, l)
	local instance = self:create {
		t = t or 0;
		b = b or 0;
		r = r or 0;
		l = l or 0;
	}
	if donot_update_size then
		instance.layout_update_size = function() end
	end
	return instance
end

---@param rect ui_rect
function vertical_layouter_component:layout_update_size(rect)
	local h = self.t + self.b
	local w = self.l + self.r
	for i = 1, #rect.children do
		local child = rect.children[i]
		h = h + child.h
		w = math.max(w, child.w)
	end
	rect.h = h
end

---@param rect ui_rect
function vertical_layouter_component:layout_update(rect)
	local pos = self.t
	for i = 1, #rect.children do
		local child = rect.children[i]
		child.x = math.floor((rect.w - self.r - self.l - child.w) / 2)
		child.y = pos
		pos = pos + child.h
	end
end

return vertical_layouter_component
