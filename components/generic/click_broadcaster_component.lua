
local click_broadcaster_component = require "love-util.class" "click_broadcaster_component":extends(require "love-ui.components.generic.ui_rect_component")

function click_broadcaster_component:new()
	return self:create {
		on_was_triggered_key = false,
		on_was_triggered_args = {},
		on_was_triggered_subscribers = {},
	}
end

---@param root ui_rect
function click_broadcaster_component:on_ready(root)
	if not root.components or not self.on_was_triggered_key then
		return
	end

	for ui_rect, component in root:foreach_component_method(self.on_was_triggered_key) do
		self.on_was_triggered_subscribers[#self.on_was_triggered_subscribers+1] = function(self, ui_rect, ...)
			component[self.on_was_triggered_key](component, ui_rect, self, ...)
		end
	end
end

function click_broadcaster_component:was_triggered(ui_rect)
	for i=1,#self.on_was_triggered_subscribers do
		self.on_was_triggered_subscribers[i](self, ui_rect, unpack(self.on_was_triggered_args))
	end
end

return click_broadcaster_component