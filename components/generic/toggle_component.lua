
local toggle_component = require "love-util.class" "toggle_component":extends(require "love-ui.components.generic.ui_rect_component")

function toggle_component:new()
	return self:create {
		toggle_state = false,
		toggle_true_enabled_components = {},
		toggle_false_enabled_components = {},
		on_was_toggled_key = false,
		on_was_toggled_args = {},
		on_was_toggled_subscribers = {},
	}
end

function toggle_component:set_toggle_state(on)
	self.toggle_state = on
	-- for i=1,#self.toggle_true_enabled_components do
	-- 	local component = self.toggle_true_enabled_components[i]
	-- 	if component then
	-- 		require "log" (component)
	-- 		component:set_enabled(on)
	-- 	end
	-- end
	-- for i=1,#self.toggle_false_enabled_components do
	-- 	local component = self.toggle_false_enabled_components[i]
	-- 	if component then
	-- 		component:set_enabled(not on)
	-- 	end
	-- end
end

---@param root ui_rect
function toggle_component:on_ready(root)
	if not root.components then
		return
	end

	if self.on_was_toggled_key then
		for ui_rect, component in root:foreach_component_method(self.on_was_toggled_key) do
			self.on_was_toggled_subscribers[#self.on_was_toggled_subscribers+1] = function(self, ui_rect, ...)
				component[self.on_was_toggled_key](component, ui_rect, self, ...)
			end
		end
	end

	self:set_toggle_state(self.toggle_state)
end

function toggle_component:was_triggered(ui_rect)
	self:set_toggle_state(not self.toggle_state)
	for i=1,#self.on_was_toggled_subscribers do
		self.on_was_toggled_subscribers[i](self, ui_rect, unpack(self.on_was_toggled_args))
	end
end

return toggle_component