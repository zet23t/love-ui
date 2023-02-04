---@class vertical_layouter_component : ui_rect_component
local vertical_layouter_component = require "love-util.class" "vertical_layouter_component":extends(require "love-ui.components.generic.ui_rect_component")

---@param donot_update_size boolean|nil
---@param t number|nil
---@param r number|nil
---@param b number|nil
---@param l number|nil
---@return vertical_layouter_component
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

function vertical_layouter_component:set_horizontal_expand_enabled(enabled)
	self.horizontal_expand_enabled = enabled
	return self
end

---@param rect ui_rect
function vertical_layouter_component:layout_update_size(rect)
	local h = self.t + self.b
	local w = self.l + self.r

	for i = 1, #rect.children do
		local child = rect.children[i]
		if not child.ignore_layouting then
			if self.horizontal_expand_enabled then
				child.w = rect.w
			end
			child:do_layout_size_update()
			h = h + child.h
		end
		-- print(child.h)
		-- w = math.max(w, child.w)
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
