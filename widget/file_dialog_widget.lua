local ui_rect                       = require "love-ui.ui_rect"
local parent_size_matcher_component = require "love-ui.components.layout.parent_size_matcher_component"
local rectfill_component            = require "love-ui.components.generic.rectfill_component"
local weighted_position_component   = require "love-ui.components.layout.weighted_position_component"
local parent_limited_size_component = require "love-ui.components.layout.parent_limited_size_component"
local text_component                = require "love-ui.components.generic.text_component"
local clip_component                = require "love-ui.components.generic.clip_component"

---@class file_dialog_widget : object
---@field screen_rect ui_rect the full screen rect
local file_dialog_widget = require "love-util.class" "file_dialog_widget"

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

	self.dialog_panel = ui_rect:new(0, 0, 300, 200, self.screen_rect, weighted_position_component:new(),
		parent_limited_size_component:new(300, 200))
	ui_theme:decorate_window_skin(self.dialog_panel, "Open file")

	self.close_x_button = ui_rect:new(0, 0, 8, 8, self.dialog_panel, weighted_position_component:new(1, 0, 1, 2))
	ui_theme:decorate_sprite(self.close_x_button, ui_theme.icon.close_x)
	ui_theme:decorate_on_click(self.close_x_button, function() self:close() end)

	self.cancel_button = ui_rect:new(0, 0, 40, 9, self.dialog_panel, weighted_position_component:new(1, 1, 0, 3, 3))
	ui_theme:decorate_button_skin(self.cancel_button, "Cancel", function() self:close() end)

	self.open_button = ui_rect:new(0, 0, 40, 9, self.dialog_panel, weighted_position_component:new(1, 1, 0, 45, 3))
	ui_theme:decorate_button_skin(self.open_button, "Open", function() self:close() end)

	self.file_name = ui_rect:new(3, 0, 0, 9, self.dialog_panel,
		rectfill_component:new(7, 1),
		text_component:new("here will be filename.txt", 1, 2, 2, 2, 2, 0, .5),
		{
			layout_update = function(c, rect) rect.y, rect.w = rect.parent.h - 12, rect.parent.w - 90 end;
			mouse_enter = function(c, rect) rect:trigger_on_components("set_fill", 15) end;
			mouse_exit = function(c, rect) rect:trigger_on_components("set_fill", 7) end;
		}
	)

	self.directory_hierarchy = ui_rect:new(3, 10, 100, 100, self.dialog_panel,
		rectfill_component:new(7, 1),
		{
			layout_update = function(c, rect) rect.h = rect.parent.h - 23 end;
		}
	)

	self.directory_hierarchy_clip_area = ui_rect:new(0,0,0,0, self.directory_hierarchy,
		parent_size_matcher_component:new(1,1,1,1))
	self.directory_hierarchy_list = ui_rect:new(0,0,0,0)

	self:set_directory(love.filesystem.getWorkingDirectory())

	return self
end

function file_dialog_widget:set_directory(path)

end

function file_dialog_widget:close()
	self.screen_rect:remove()
end

function file_dialog_widget:set_parent(ui_rect)
	self.screen_rect:set_parent(ui_rect)
	self.screen_rect:do_layout()
end

return file_dialog_widget
