---@class linear_layouter_component : ui_rect_component
local linear_layouter_component = require "love-util.class" "linear_layouter_component":extends(require "love-ui.components.generic.ui_rect_component")

---@param donot_update_size boolean|nil
---@param axis 1|2
---@param t number|nil
---@param r number|nil
---@param b number|nil
---@param l number|nil
---@return linear_layouter_component
function linear_layouter_component:new(axis, donot_update_size, t, r, b, l, spacing)
	local instance = self:create {
		axis = axis or 1,
		t = t or 0;
		b = b or 0;
		r = r or 0;
		l = l or 0;
		spacing = spacing or 0;
	}
	if donot_update_size then
		instance.layout_update_size = function() end
	end
	return instance
end

function linear_layouter_component:set_minor_axis_fit_enabled(enabled)
	self.minor_axis_fit_enabled = enabled
	return self
end

function linear_layouter_component:set_minor_axis_expand_children_enabled(enabled)
	self.minor_axis_expand_children_enabled = enabled
	return self
end

---@param rect ui_rect
function linear_layouter_component:layout_update_size(rect)
	local h = self.t + self.b
	local w = self.l + self.r
	local major_val, minor_val, major_key, minor_key = w, h, "w", "h"
	if self.axis == 2 then
		major_val, minor_val = minor_val, major_val
		major_key, minor_key = minor_key, major_key
	end

	local max_minor_val = minor_val

	for i = 1, #rect.children do
		local child = rect.children[i]
		if not child.ignore_layouting and child:is_enabled() then
			if self.minor_axis_expand_children_enabled then
				child[minor_key] = rect[minor_key] - minor_val
			elseif self.minor_axis_fit_enabled then
				max_minor_val = math.max(max_minor_val, child[minor_key] + minor_val)
			end
			child:do_layout_size_update()
			major_val = major_val + child[major_key] + (i > 1 and self.spacing or 0)
		end
	end

	rect[major_key] = major_val
	if self.minor_axis_fit_enabled then
		rect[minor_key] = max_minor_val
	end
end
local default_alignment = {x = 0.5, y = 0.5, padding_left = 0, padding_right = 0, padding_top = 0, padding_bottom = 0}
---@param rect ui_rect
function linear_layouter_component:layout_update(rect)
	local pos = self.l
	local major_a, major_b = self.t, self.b
	local major_pos, minor_pos = "y", "x"
	local major_size, minor_size = "w", "h"
	local major_padding_0, major_padding_1 = "padding_top", "padding_bottom"
	if self.axis == 2 then
		pos = self.t
		major_a, major_b = self.l, self.r
		major_pos, minor_pos = "x", "y"
		major_size, minor_size = "h", "w"
		major_padding_0, major_padding_1 = "padding_left", "padding_right"
	end

	for i = 1, #rect.children do
		local child = rect.children[i]
		if child:is_enabled() then
			local layout_alignment = (child.layout_alignment or default_alignment)
			local align = layout_alignment[major_pos] or default_alignment[major_pos]
			local padding_0, padding_1 = layout_alignment[major_padding_0] or 0, layout_alignment[major_padding_1] or 0
			-- print(major_padding_0, padding_0, major_padding_1, padding_1,align)
			
			child[major_pos] = math.floor((rect[minor_size] - major_b - major_a - child[minor_size] - padding_0 - padding_1) * align + major_a + padding_0)
			child[minor_pos] = pos
			pos = pos + child[major_size] + self.spacing
		end
	end
end

return linear_layouter_component
