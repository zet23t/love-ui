local pico8api = require "love-ui.pico8api"
local text_component = require "love-ui.components.generic.text_component"
local sprite_component = require "love-ui.components.generic.sprite_component"
local rectfill_component = require "love-ui.components.generic.rectfill_component"
local desuffixed_pairs = require "love-util.desuffix_pairs"
local max = math.max
local abs = math.abs

local menu_widget = require "love-util.class" "menu_widget":extends(require "love-ui.components.generic.ui_rect_component")

function menu_widget:new(menu, owner)
	return menu_widget:create { menu = menu, owner = owner, show_count = 1, timeout = 5 }
end

function menu_widget:init(ui_rect)
	local menu_c = self
	ui_rect:add_component(rectfill_component:new(6, 5))
	local y = 2
	local maxw = 10
	local menu = self.menu
	if menu.get_menu then
		menu = assert(menu:get_menu())
	end
	for k, v in desuffixed_pairs(menu) do
		local w = pico8api:text_width(k) + 20
		maxw = max(w, maxw)
	end
	for k, v, icon in desuffixed_pairs(menu) do
		local entry = ui_rect:new(1, y, maxw, k == "" and 1 or 8, ui_rect)
		if k ~= "" then
			local r = entry:add_component(rectfill_component:new(6))
			entry:add_component {
				mouse_enter = function() r.fill = 7 end,
				mouse_exit = function() r.fill = 6 end,
			}
			entry:add_component(text_component:new(k, 0, 0, 0, 0, 11, 0))
			local is_table = type(v) == "table"
			local event_handler = entry:add_component {
				was_triggered = function(self, ui_rect_e, mx, my)
					local fn = type(v) == "function" and v or v.func
					if fn then
						fn(ui_rect_e, mx, my, k)
						ui_rect:remove()
					end
				end,
				draw = function(self, ui_rect_e, mx, my)
					if is_table and v.draw then
						v:draw(ui_rect_e, mx, my)
					end
				end
			}

			if is_table and not v.no_sub_menu then
				local submenu_c
				function event_handler:draw(ui_rect)
					local x, y = ui_rect:to_world(ui_rect.w - 5, 1)
					for i = 0, 6 do
						pico8api:rectfill(x, y + i, x + 3 - abs(i - 3), y + i, 5)
					end
				end

				function event_handler:is_mouse_over(ui_rect)
					local x, y = ui_rect:to_world(ui_rect.w - 2)
					submenu_c = ui_rect:new(x, y, 10, 10, ui_rect:root()):add_component(menu_widget:new(v, menu_c))
				end
			end
			if icon then
				entry:add_component(sprite_component:new(icon, 1))
			end
			y = y + 9
		else
			entry:add_component(rectfill_component:new(5))
			y = y + 3
		end
	end
	ui_rect:set_rect(nil, nil, maxw + 2, y + 1)
	--local x,y = ui_rect:to_world()
	if ui_rect.x + ui_rect.w > pico8api:screen_size() then
		ui_rect.x = pico8api:screen_size() - ui_rect.w
	end
end

function menu_widget:show(change)
	self.show_count = self.show_count + change
	return self.show_count > 0 and self
end

function menu_widget:update(ui_rect)
	self.timeout = self.timeout - 1
	if self.timeout < 0 then
		ui_rect:remove()
	end
end

function menu_widget:is_mouse_over(ui_rect)
	if self.owner then self.owner.timeout = 5 end
	self.timeout = 5
end

return menu_widget