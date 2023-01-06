--- A component that will populate and size its rect with data provided through functions, building
--- a vertical or horizontal list of identically sized items. 
---@class virtual_list_widget : ui_rect_component
---@field axis 1|2
---@field list_entry_size number
---@field fn_acquire_element_by_index fun(index:integer):ui_rect
---@field fn_release_element fun(ui_rect:ui_rect)
---@field fn_get_count fun():integer
---@field active_elements ui_rect[]
local virtual_list_widget = require "love-util.class" "virtual_list_widget":extends(require "love-ui.components.generic.ui_rect_component")

---@param axis 1|2
---@param list_entry_size number
---@param fn_get_count fun():integer
---@param fn_acquire_element_by_index fun(index:integer):ui_rect
---@param fn_release_element fun(ui_rect:ui_rect)|nil
---@return virtual_list_widget
function virtual_list_widget:new(axis, list_entry_size, fn_get_count, fn_acquire_element_by_index, fn_release_element)
	return virtual_list_widget:create {
		list_entry_size = list_entry_size,
		axis = axis,
		fn_acquire_element_by_index = fn_acquire_element_by_index,
		fn_release_element = fn_release_element,
		fn_get_count = fn_get_count,
		active_elements = {}
	}
end

---@param rect ui_rect
function virtual_list_widget:layout_update_size(rect)
	if self.axis == 1 then
		rect.w = math.ceil(self.fn_get_count() * self.list_entry_size)
	else
		rect.h = math.ceil(self.fn_get_count() * self.list_entry_size)
	end
end

function virtual_list_widget:release_all()
	self.release_all_on_update = true
end

---@param rect ui_rect
function virtual_list_widget:layout_update(rect)
	local pw, ph = rect.parent:get_size()
	local entry_size = self.list_entry_size
	local ps = self.axis == 1 and pw or ph
	local start_pos = self.axis == 1 and rect.x or rect.y
	local start_index = math.max(1, math.floor(-start_pos / entry_size))
	local end_index = math.min(self.fn_get_count(), math.ceil((ps - start_pos) / entry_size))

	for i, ui_rect in pairs(self.active_elements) do
		if i < start_index or i > end_index or self.release_all_on_update then
			ui_rect:remove()
			if self.fn_release_element then
				self.fn_release_element(ui_rect)
			end
			self.active_elements[i] = nil
		end
	end

	self.release_all_on_update = false

	for i = start_index, end_index do
		if not self.active_elements[i] then
			local element = self.fn_acquire_element_by_index(i)
			self.active_elements[i] = element
			element:set_parent(rect)
			if self.axis == 1 then
				element:set_rect((i - 1) * entry_size, 0, entry_size, rect.h)
			else
				element:set_rect(0, (i - 1) * entry_size, rect.w, entry_size)
			end
		end
	end
end

return virtual_list_widget
