local nativefs                      = require "nativefs"
local ui_rect                       = require "love-ui.ui_rect"
local parent_size_matcher_component = require "love-ui.components.layout.parent_size_matcher_component"
local rectfill_component            = require "love-ui.components.generic.rectfill_component"
local weighted_position_component   = require "love-ui.components.layout.weighted_position_component"
local parent_limited_size_component = require "love-ui.components.layout.parent_limited_size_component"
local text_component                = require "love-ui.components.generic.text_component"
local clip_component                = require "love-ui.components.generic.clip_component"
local pico8api                      = require "love-ui.pico8api"
local clip_stack                    = require "love-ui.clip_stack"
local scrollbar_widget              = require "love-ui.widget.scrollbar_widget"

---@class file_dialog_widget : object
---@field screen_rect ui_rect the full screen rect
---@field directory_hierarchy_list ui_rect
local file_dialog_widget = require "love-util.class" "file_dialog_widget"

---@param ui_theme ui_theme
---@return file_dialog_widget
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

	self.directory_hierarchy_scroll = ui_rect:new(0, 0, 8, 100, self.directory_hierarchy,
		weighted_position_component:new(1, 0),
		parent_size_matcher_component:new(0, true, 0, true),
		scrollbar_widget:new_themed(2, ui_theme))

	self.directory_hierarchy_clip_area = ui_rect:new(0, 0, 0, 0, self.directory_hierarchy,
		parent_size_matcher_component:new(1, 8, 1, 1),
		clip_component:new()
	)
	local line_height = 9
	self.directory_hierarchy_list = ui_rect:new(0, 0, 0, 0, self.directory_hierarchy_clip_area, {
		layout_update_size = function(comp, ui_rect)
			ui_rect.h = #self.directory_hierarchy_list * line_height
			ui_rect.w = ui_rect.parent.w
		end;
		draw = function(comp, ui_rect)
			-- love.graphics.setScissor()
			local x, y = ui_rect:to_world()
			local cx1, cy1, cw, ch = clip_stack:current_rect()
			local cy2 = cy1 + ch
			local start = math.max(1, math.floor((y - cy1) / line_height))
			for i = start, math.min(#self.directory_hierarchy_list, math.ceil(start + ch / line_height) - 1) do
				local dir_info = self.directory_hierarchy_list[i]
				local px = x + 4 * dir_info.level
				local py = y + (i - 1) * line_height
				pico8api:spr(dir_info.is_opened and ui_theme.icon.open_folder or ui_theme.icon.closed_folder, px, py)
				pico8api:print(dir_info.file_name, px + 10, py + 2, 1)
			end
		end
	})


	self:set_directory(love.filesystem.getWorkingDirectory())

	return self
end

function file_dialog_widget:set_directory(path)
	local current_path = ""

	self.directory_hierarchy_list = {}
	local function amend(current_path, level)
		level = level + 1
		local files = nativefs.getDirectoryItems(current_path)
		table.sort(files, function(a, b) return a:lower() < b:lower() end)
		for i = 1, #files do
			local file_path = current_path .. files[i]
			if nativefs.getInfo(file_path, "directory") then
				local is_opened = file_path == path:sub(1, #file_path)
				self.directory_hierarchy_list[#self.directory_hierarchy_list + 1] = {
					level = level;
					is_opened = is_opened;
					file_path = file_path;
					file_name = files[i];
					directory = current_path;
				}
				if is_opened then
					amend(file_path .. "/", level + 1)
				end
			end
		end
	end

	amend(path:match "[^/]+/", 0)
end

function file_dialog_widget:close()
	self.screen_rect:remove()
end

function file_dialog_widget:set_parent(ui_rect)
	self.screen_rect:set_parent(ui_rect)
	self.screen_rect:do_layout()
end

return file_dialog_widget
