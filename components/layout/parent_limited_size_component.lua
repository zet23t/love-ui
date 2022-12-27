---@class parent_limited_size_component : ui_rect_component
---@field max_w number
---@field max_h number
local parent_limited_size_component = require "love-util.class" "parent_limited_size_component":extends(require "love-ui.components.generic.ui_rect_component")

---@param max_w number
---@param max_h number
---@return parent_limited_size_component
function parent_limited_size_component:new(max_w, max_h)
	return self:create { max_w = max_w, max_h = max_h }
end

function parent_limited_size_component:layout_update_size(ui_rect)
	if not ui_rect.parent then return end
	ui_rect.w, ui_rect.h = math.min(self.max_w, ui_rect.parent.w), math.min(self.max_h, ui_rect.parent.h)
end

return parent_limited_size_component