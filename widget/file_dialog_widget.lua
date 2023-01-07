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
local scroll_area_widget            = require "love-ui.widget.scroll_area_widget"
local virtual_list_widget           = require "love-ui.widget.virtual_list_widget"
local sprite_component              = require "love-ui.components.generic.sprite_component"

---@class file_dialog_widget : object
---@field screen_rect ui_rect the full screen rect
---@field directory_hierarchy_list ui_rect
---@field opened_directories table
local file_dialog_widget = require "love-util.class" "file_dialog_widget"


file_dialog_widget.indent_per_level = 4

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

	self.opened_directories = {}

	local width = 600
	local height = 400

	self.dialog_panel = ui_rect:new(0, 0, width, height, self.screen_rect, weighted_position_component:new(),
		parent_limited_size_component:new(width, height))
	ui_theme:decorate_window_skin(self.dialog_panel, "Open file")

	self.close_x_button = ui_rect:new(0, 0, 16, 16, self.dialog_panel, weighted_position_component:new(1, 0, 2, 4))
	ui_theme:decorate_sprite(self.close_x_button, ui_theme.icon.close_x)
	ui_theme:decorate_on_click(self.close_x_button, function() self:close(true) end)

	self.cancel_button = ui_rect:new(0, 0, 80, 18, self.dialog_panel, weighted_position_component:new(1, 1, 0, 6, 6))
	ui_theme:decorate_button_skin(self.cancel_button, "Cancel", function() self:close(true) end)

	self.open_button = ui_rect:new(0, 0, 80, 18, self.dialog_panel, weighted_position_component:new(1, 1, 0, 90, 6))
	ui_theme:decorate_button_skin(self.open_button, "Open", function() self:close() end)

	self.file_name = ui_rect:new(3, 0, 0, 18, self.dialog_panel,
		rectfill_component:new(7, 1),
		text_component:new("", 1, 2, 2, 2, 2, 0, .5),
		{
			layout_update = function(c, rect) rect.y, rect.w = rect.parent.h - 24, rect.parent.w - 180 end;
			mouse_enter = function(c, rect) rect:trigger_on_components("set_fill", 15) end;
			mouse_exit = function(c, rect) rect:trigger_on_components("set_fill", 7) end;
		}
	)

	self.directory_hierarchy = ui_rect:new(6, 20, 200, 100, self.dialog_panel, {
		layout_update = function(cmp, rect)
			rect.h = rect.parent.h - rect.y - 28
			self.directory_hierarchy_scroll_view.scroll_content.w = self.max_width
		end
	})
	self.directory_hierarchy_scroll_view = self.directory_hierarchy:add_component(scroll_area_widget:new(ui_theme))

	local line_height = 9
	self.directory_hierarchy_scroll_view.scroll_content:add_component(virtual_list_widget:new(2, 18,
		function() return #self.directory_hierarchy_list end,
		function(index)
			local element = self.directory_hierarchy_list[index]
			local function select(cmp, rect, mx, my, top)
				if not top then return end
				self.opened_directories[element.file_path] = true
				self:set_directory(element.file_path)
			end

			-- print(index,#self.directory_hierarchy_list)
			local rect = ui_rect:new(0, 0, 0, 0, nil, rectfill_component:new(nil, nil, .25))
			local text_and_icon = ui_rect:new(element.level * self.indent_per_level + 16, 0, 10 + element.text_width, 18, rect,
				sprite_component:new(element.is_opened and ui_theme.icon.open_folder or ui_theme.icon.closed_folder, 0),
				text_component:new(element.file_name, 0, 0, 0, 0, 18, 0, .5),
				{ was_triggered = select })
			local toggle_open = ui_rect:new(element.level * self.indent_per_level, 0, 16, 16, rect,
				sprite_component:new(element.is_opened and ui_theme.icon.tiny_triangle_down or ui_theme.icon.tiny_triangle_right, 3,
					3),
				{
					was_triggered = function()
						self.opened_directories[element.file_path] = not self.opened_directories[element.file_path]
						self:set_directory(self.current_directory)
					end
				})
			rect:add_component
			{
				mouse_enter = function(component, rect) rect:trigger_on_components("set_fill", 2) end;
				mouse_exit = function(component, rect) rect:trigger_on_components("set_fill", nil) end;
				was_triggered = select;
			}
			return rect
		end))

	self.files_view = ui_rect:new(210, 20, 100, 100, self.dialog_panel, {
		layout_update = function(cmp, rect)
			rect.h = rect.parent.h - rect.y - 28
			rect.w = rect.parent.w - rect.x - 6
		end
	})
	self.files_view_scroll_view = self.files_view:add_component(scroll_area_widget:new(ui_theme))
	self.files_view_scroll_view.scroll_content:add_component(virtual_list_widget:new(2, 18,
		function() return #self.file_list end,
		function(index)
			local element = self.file_list[index]
			local rect = ui_rect:new(0, 0, 0, 0, nil, rectfill_component:new(nil, nil, .25))
			ui_rect:new(0, 0, 100, 18, rect,
				sprite_component:new(element.is_directory and ui_theme.icon.closed_folder or ui_theme.icon.generic_file),
				text_component:new(element.file_name, 0, 0, 0, 0, 20, 0))
			rect:add_component {
				mouse_enter = function(c, rect) rect:trigger_on_components("set_fill", 2) end;
				mouse_exit = function(c, rect) rect:trigger_on_components("set_fill", nil) end;
				was_triggered = function()
					if element.is_directory then
						self:set_directory(element.file_path)
						return
					end
					self:set_file_name(element.file_name)
				end
			}
			return rect
		end))

	self:set_directory(love.filesystem.getWorkingDirectory())

	return self
end

function file_dialog_widget:show(parent_rect, on_closed)
	self:set_parent(parent_rect)
	self.on_closed = on_closed
end

function file_dialog_widget:on_closed(selected_file)
	print("Selected file for opening: ", selected_file)
end

function file_dialog_widget:set_file_name(name)
	self.file_name:trigger_on_components("set_text", name)
	self.current_file_name = name
end

function file_dialog_widget:set_directory(path)
	if not path:match "/$" then path = path .. "/" end
	if path == self.current_directory then return end
	self.current_directory = path

	self.directory_hierarchy_scroll_view.scroll_content:trigger_on_components "release_all"
	self.files_view_scroll_view.scroll_content:trigger_on_components "release_all"

	self:set_file_name("")

	self.directory_hierarchy_list = {}
	self.file_list = {}

	local files = nativefs.getDirectoryItems(path)
	table.sort(files, function(a, b) return a:lower() < b:lower() end)
	for i = 1, #files do
		local file_path = path .. files[i]
		local info = nativefs.getInfo(file_path)
		if info then
			self.file_list[#self.file_list + 1] = {
				file_path = file_path;
				file_name = files[i];
				is_directory = info.type == "directory";
				is_file = info.type == "file";
				size = info.size;
				modtime = info.modtime;
			}
		end
	end
	table.sort(self.file_list, function(a, b)
		if a.is_directory ~= b.is_directory then return a.is_directory end
		return a.file_name:lower() < b.file_name:lower()
	end)

	self.max_width = 0
	local function amend(current_path, level)
		level = level + 1
		local files = nativefs.getDirectoryItems(current_path)
		table.sort(files, function(a, b) return a:lower() < b:lower() end)
		for i = 1, #files do
			local file_path = current_path .. files[i]
			if nativefs.getInfo(file_path, "directory") then
				local open_status = self.opened_directories[file_path]
				local is_opened = (open_status ~= false and file_path == path:sub(1, #file_path)) or open_status
				self.opened_directories[file_path] = is_opened
				local element = {
					level = level;
					is_opened = is_opened;
					file_path = file_path;
					file_name = files[i];
					directory = current_path;
					text_width = pico8api:text_width(files[i]);
				}
				self.directory_hierarchy_list[#self.directory_hierarchy_list + 1] = element
				self.max_width = math.max(self.max_width, self.indent_per_level * level + element.text_width + 23)
				if is_opened then
					amend(file_path .. "/", level + 1)
				end
			end
		end
	end

	amend(path:match "[^/]+/", 0)
end

function file_dialog_widget:close(is_cancelled)
	self.screen_rect:remove()
	self:on_closed(not is_cancelled and (self.current_directory .. self.current_file_name))
end

function file_dialog_widget:set_parent(ui_rect)
	self.screen_rect:set_parent(ui_rect)
	self.screen_rect:do_layout()
end

return file_dialog_widget
