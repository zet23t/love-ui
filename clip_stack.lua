local clamp = require "love-math.clamp"
local pico8api = require "love-ui.pico8api"

local clip_stack = {}
function clip_stack:push(x,y,w,h,clip_previous)
	if #clip_stack > 0 and clip_previous then
		local px1,py1,px2,py2 = unpack(clip_stack[#clip_stack])
		local x1, x2 = clamp(px1, px2, x, x + w)
		local y1, y2 = clamp(py1, py2, y, y + h)
		x,y,w,h = x1, y1, x2-x1, y2-y1
	end
	pico8api:add(clip_stack, {x,y,w,h})
	pico8api:clip(x,y,w,h)
end

function clip_stack:pop()
	pico8api:deli(clip_stack,#clip_stack)
	if #clip_stack == 0 then
		return pico8api:clip()
	end
	-- printc(unpack(clip_stack[#clip_stack]))
	pico8api:clip(unpack(clip_stack[#clip_stack]))
end

return clip_stack