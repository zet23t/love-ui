---@class file_dialog_widget : object
---@field screen_rect ui_rect the full screen rect
local file_dialog_widget = require "love-util.class" "file_dialog_widget"

local ui_rect = require "love-ui.ui_rect"
local parent_size_matcher_component = require "love-ui.components.layout.parent_size_matcher_component"
local rectfill_component = require "love-ui.components.generic.rectfill_component"
local weighted_position_component = require "love-ui.components.layout.weighted_position_component"
local parent_limited_size_component = require "love-ui.components.layout.parent_limited_size_component"

---@param ui_theme ui_theme
---@return object
function file_dialog_widget:new(ui_theme)
	---@type file_dialog_widget
	---@diagnostic disable-next-line: assign-type-mismatch
	local self = file_dialog_widget:create {}
	ui_theme = ui_theme or require "love-ui.ui_theme.ui_theme"

	self.screen_rect = ui_rect:new(0, 0, 0, 0)
	self.screen_rect:add_component(parent_size_matcher_component:new(0, 0, 0, 0))
	self.screen_rect:add_component(rectfill_component:new(1):set_alpha(.5))

	self.dialog_panel = ui_rect:new(0, 0, 300, 200, self.screen_rect, weighted_position_component:new(), parent_limited_size_component:new(300, 200))
	ui_theme:decorate_window_skin(self.dialog_panel, "Open file")

	self.close_x_button = ui_rect:new(0, 0, 8, 8, self.dialog_panel, weighted_position_component:new(1, 0, 1, 2))
	ui_theme:decorate_sprite(self.close_x_button, ui_theme.icon.close_x)
	ui_theme:decorate_on_click(self.close_x_button, function() self:close() end)

	self.cancel_button = ui_rect:new(0, 0, 40, 9, self.dialog_panel, weighted_position_component:new(1,1,0,3,3))
	ui_theme:decorate_button_skin(self.cancel_button, "Cancel", function() self:close() end)
	
	self.open_button = ui_rect:new(0,0,40,9,self.dialog_panel,weighted_position_component:new(1,1,0,45,3))
	ui_theme:decorate_button_skin(self.open_button, "Open", function() self:close() end)

	
	return self
end

function file_dialog_widget:close()
	self.screen_rect:remove()
end

function file_dialog_widget:set_parent(ui_rect)
	self.screen_rect:set_parent(ui_rect)
end

return file_dialog_widget
