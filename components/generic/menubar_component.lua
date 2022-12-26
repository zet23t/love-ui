local pico8api = require "love-ui.pico8api"
local rectfill_component = require "love-ui.components.generic.rectfill_component"
local menu_component = require "love-ui.components.generic.menu_component"
local text_component = require "love-ui.components.generic.text_component"
local desuffixed_pairs = require "love-util.desuffix_pairs"

local menubar_component = require "love-util.class" "menubar_component":extends(require "love-ui.components.generic.ui_rect_component")

---@param menubar table for example {File_1 = {Open_1=function()print"open"end}}
---@param yoffset number|nil
---@return unknown
function menubar_component:new(menubar, yoffset)
	local self = menubar_component:create { menubar = menubar }
	self.yoffset = yoffset or 9
	return self
end

function menubar_component:init(ui_rect)
	local bar = ui_rect:new(0,0,10,10,ui_rect,rectfill_component:new(6), {
		layout_update = function(cmp, ui_rect) ui_rect:set_rect(0,self.yoffset,ui_rect.parent.w,8) end
	})
	local x = 2
	for k, v in desuffixed_pairs(self.menubar) do
		-- require "log"("%s %s %s",tostring(k),tostring(v), tostring(0))
		
		local w = pico8api:text_width(k) + 6
		local start_x = x
		x = x + w + 5
		local menu_c, entry
		local rf = rectfill_component:new(6)
		entry = ui_rect:new(0, 0, 10, 10, ui_rect,
			rf, {
				layout_update = function(cmp, ui_rect)
					ui_rect:set_rect(start_x, self.yoffset, w + 2, 8)
				end,
				mouse_enter = function()
					rf.fill = 7
				end,
				mouse_exit = function()
					rf.fill = 6
				end,
				is_mouse_over = function()
					if menu_c then menu_c.timeout = 5 end
				end,
				was_triggered = function()
					if type(v) == "function" then
						return v()
					end
					local x, y = ui_rect:to_world(start_x, entry.y + 8)
					menu_c = ui_rect:new(x, y, 10, 10, ui_rect:root()):add_component(menu_component:new(v))
				end
			}, text_component:new(k, 0,0,0,1))
	end
end

return menubar_component