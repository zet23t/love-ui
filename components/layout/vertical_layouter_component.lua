---@class vertical_layouter_component : ui_rect_component
local vertical_layouter_component = require "love-util.class" "vertical_layouter_component":extends(require "love-ui.components.generic.ui_rect_component")

function vertical_layouter_component:new(donot_update_size)
	local instance = self:create {}
	if donot_update_size then
		instance.layout_update_size = function() end
	end
	return instance
end

---@param rect ui_rect
function vertical_layouter_component:layout_update_size(rect)
	local h = 0
	local w = 0
	for i = 1, #rect.children do
		local child = rect.children[i]
		h = h + child.h
		w = math.max(w, child.w)
	end
	rect.h = h
end

---@param rect ui_rect
function vertical_layouter_component:layout_update(rect)
	local pos = 0
	for i = 1, #rect.children do
		local child = rect.children[i]
		child.x = math.floor((rect.w - child.w) / 2)
		child.y = pos
		pos = pos + child.h
	end
end

return vertical_layouter_component
