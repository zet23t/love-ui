local text_component                = require "love-ui.components.generic.text_component"
local sprite_component              = require "love-ui.components.generic.sprite_component"
local rectfill_component            = require "love-ui.components.generic.rectfill_component"
local vertical_layouter_component   = require "love-ui.components.layout.vertical_layouter_component"
local parent_size_matcher_component = require "love-ui.components.layout.parent_size_matcher_component"
local ui_rect                       = require "love-ui.ui_rect"
local weighted_position_component   = require "love-ui.components.layout.weighted_position_component"
local late_command                  = require "love-util.late_command"

---@class dropdown_widget
---@field options string[]
---@field selected string
---@field ui_theme ui_theme
local dropdown_widget = require "love-util.class" "dropdown_widget":extends(require "love-ui.components.generic.ui_rect_component")

---@param ui_theme ui_theme
---@param options string[]
---@return dropdown_widget
function dropdown_widget:new(ui_theme, selected, options)
	return self:create { options = options, selected = selected or options[1] or "<???>", ui_theme = ui_theme }
end

function dropdown_widget:set_selected_value(value)
	self.selected = value
	self.text_component:set_text(value)
end

function dropdown_widget:on_value_changed(value)
end

---@param rect ui_rect
function dropdown_widget:init(rect)
	local function on_open()
		local overlay = ui_rect:new(0, 0, 0, 0, rect:root(), parent_size_matcher_component:new())
		local function close_overlay()
			late_command(function() overlay:remove() end)
		end

		overlay:add_component {
			was_triggered = function(cmd, rect)
				if rect.flags.is_top_hit then
					close_overlay()
				end
			end
		}

		local popup_rect = ui_rect:new(0, 0, 0, 0, overlay, rectfill_component:new(7, 1))
		popup_rect:add_component {
			layout_update = function(cmp, r)
				local x, y = rect:to_world()
				r.x = x
				r.y = y + rect.h
				r.w = rect.w
				r.h = 2 + #self.options * 20
			end
		}
		popup_rect:add_component(vertical_layouter_component:new(false, 1,1,1,1):set_horizontal_expand_enabled(true))
		for i = 1, #self.options do
			local option = ui_rect:new(0, 0, popup_rect.w, 20, popup_rect)
			local value = self.options[i]
			option:add_component(rectfill_component:new(nil, nil, .2))
			option:add_component(text_component:new(value,1,0,5,0,5,0))
			option:add_component {
				mouse_enter = function(cmp, rect)
					option:trigger_on_components("set_fill", 1)
				end;
				mouse_exit = function(cmp, rect)
					option:trigger_on_components("set_fill")
				end;
				was_triggered = function(cmp, rect)
					close_overlay()
					self:set_selected_value(value)
					self:on_value_changed(value)
				end
			}
		end

	end

	rect:add_component(rectfill_component:new(7, 1))
	self.text_component = rect:add_component(text_component:new(self.selected, 1, 0, 20, 0, 4, 0))
	local button_rect = ui_rect:new(0, 0, 16, rect.h, rect, weighted_position_component:new(1, 0))
	self.ui_theme:decorate_button_skin(button_rect, nil, nil, on_open)
	button_rect:add_component(sprite_component:new(self.ui_theme.icon.tiny_triangle_down, 5, 7))
end

return dropdown_widget
