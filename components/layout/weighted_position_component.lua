--- positions the ui_rect within the boundaries of its parent component
---@class weighted_position_component : ui_rect_component
---@field wx number weighted x position
---@field wy number weighted y position
---@field padding_top number padding distance from top
---@field padding_right number padding distance from right
---@field padding_bottom number padding distance from bottom
---@field padding_left number padding distance from left
local weighted_position_component = require "love-util.class" "weighted_position_component":extends(require "love-ui.components.generic.ui_rect_component")
weighted_position_component.offset_x = 0
weighted_position_component.offset_y = 0

---@param wx number|nil defaults to 0.5
---@param wy number|nil defaults to 0.5
---@param padding_top number|nil defaults to 0
---@param padding_right number|nil defaults to 0
---@param padding_bottom number|nil defaults to 0
---@param padding_left number|nil defaults to 0
---@return weighted_position_component
function weighted_position_component:new(wx, wy, padding_top, padding_right, padding_bottom, padding_left)
	return weighted_position_component:create {
		wx = wx or .5;
		wy = wy or .5;
		padding_top = padding_top or 0;
		padding_right = padding_right or 0;
		padding_bottom = padding_bottom or 0;
		padding_left = padding_left or 0;
	}
end

function weighted_position_component:set_weight(wx,wy)
	self.wx = wx or self.wx
	self.wy = wy or self.wy
	return self
end

function weighted_position_component:set_alignto_rect(rect)
	self.alignto_rect = rect
	return self
end

function weighted_position_component:set_offset(x,y)
	self.offset_x = x
	self.offset_y = y
	return self
end

function weighted_position_component:layout_update(ui_rect)
	local alignto = self.alignto_rect or ui_rect.parent
	if not alignto then return end
	local w, h = ui_rect.w, ui_rect.h
	local pw, ph = alignto:get_size()
	pw, ph = pw - self.padding_right - self.padding_left, ph - self.padding_top - self.padding_bottom
	local dw, dh = pw - w, ph - h
	local awx, awy = alignto:to_world(0, 0)
	local lx, ly = ui_rect.parent:to_local(awx, awy)
	ui_rect.x, ui_rect.y = math.floor(dw * self.wx + self.padding_left + .5 + self.offset_x) - lx, math.floor(dh * self.wy + self.padding_top + .5 + self.offset_y) - ly
end

return weighted_position_component
