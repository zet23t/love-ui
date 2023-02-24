local uitk         = require "love-ui.uitk"
local pico8api     = require "love-ui.pico8api"
local ui_rect      = require "love-ui.ui_rect"
local late_command = require "love-util.late_command"

local canvas = uitk:new()

love.keyboard.keysPressed = {}

return function(options)
	local root_rect
	local function call(name,...)
		if options[name] then
			return options[name](...)
		end
	end

	function love.keypressed(key, scancode)
		love.keyboard.keysPressed[key] = true
		uitk:keypressed(key)
		call("keypressed", key, scancode)
	end

	function love.load()
		love.mouse.setVisible(false)
		love.graphics.setDefaultFilter("nearest", "nearest")
		pico8api:load("lib/love-ui/uitk.png", "lib/love-ui/pico8-font.png")
		root_rect = ui_rect:new()
		call("load", root_rect)
	end

	function love.textinput(char)
		uitk:textinput(char)
		call("textinput", char)
	end

	function love.keyboard.wasPressed(key)
		return love.keyboard.keysPressed[key]
	end

	function love.wheelmoved(x, y)
		uitk:mouse_wheelmoved(x, y)
		call("wheelmoved", x, y)
	end

	function love.update(dt)
		call("update", dt)
		canvas:update(root_rect)
		late_command:flush()
		love.keyboard.keysPressed = {}
	end

	local background_color = options.background_color or {.7, .7, .7, 0}
	function love.draw()
		local screen_x = love.graphics.getWidth()
		local screen_y = love.graphics.getHeight()
		love.graphics.reset()
		love.graphics.clear(background_color)

		call "draw"

		if options.target_resolution_width then
			local target_x = options.target_resolution_width
			
			local ui_scale = screen_x / target_x
			ui_scale = math.max(1, math.floor(ui_scale - .3))
			love.graphics.scale(ui_scale, ui_scale)
			local w = math.floor(screen_x / ui_scale)
			local h = math.floor(screen_y / ui_scale)
			root_rect:set_rect(0, 0, w, h)
		else
			root_rect:set_rect(0, 0, screen_x, screen_y)
		end

		call "draw_pre_gui"
		
		canvas:draw(root_rect)
		late_command:flush()

		call "draw_post_gui"
	end

	return root_rect
end
