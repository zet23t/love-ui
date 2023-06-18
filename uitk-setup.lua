local uitk         = require "love-ui.uitk"
local pico8api     = require "love-ui.pico8api"
local ui_rect      = require "love-ui.ui_rect"
local late_command = require "love-util.late_command"
local bench        = require "love-util.bench"

local canvas = uitk:new()

love.keyboard.wasPressedTable = {}
love.keyboard.keyPressedDownCount = 0
return function(options)
	local root_rect
	local function call(name,...)
		if options[name] then
			return options[name](...)
		end
	end

	function love.keyreleased(key, scancode)
		love.keyboard.keyPressedDownCount = love.keyboard.keyPressedDownCount - 1
	end

	function love.keypressed(key, scancode, is_repeat)
		if not is_repeat then
			love.keyboard.keyPressedDownCount = love.keyboard.keyPressedDownCount + 1
		end
		love.keyboard.wasPressedTable[key] = true
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

	---@param key love.KeyConstant
	---@return boolean
	function love.keyboard.wasPressed(key)
		return love.keyboard.wasPressedTable[key]
	end

	function love.wheelmoved(x, y)
		uitk:mouse_wheelmoved(x, y)
		call("wheelmoved", x, y)
	end

	function love.update(dt)
		call("update", dt)
		canvas:update(root_rect)
		late_command:flush()
		love.keyboard.wasPressedTable = {}
	end

	local background_color = options.background_color or {.7, .7, .7, 0}
	function love.draw()
		local b = bench "uitk-setup:draw"
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
		elseif options.target_scale then
			local ui_scale = options.target_scale
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
		b()

		local uitk_vars = require "love-ui.uitk_vars"
		uitk_vars.stats = love.graphics.getStats()
	end

	return root_rect
end
