local clip_stack = require "love-ui.clip_stack"

---@class clip_component : ui_rect_component
local clip_component = require "love-util.class" "clip_component":extends(require "love-ui.components.generic.ui_rect_component")

clip_component.is_clipping_mouse = true

function clip_component:new(t, r, b, l)
	return clip_component:create { t = t or 0, r = r or 0, b = b or 0, l = l or 0 }
end

function clip_component:pre_draw(ui_rect)
	local x, y = ui_rect:to_world(self.l, self.t)
	clip_stack:push(x, y,
		ui_rect.w - self.l - self.r,
		ui_rect.h - self.t - self.b, true)
end

function clip_component:post_draw()
	clip_stack:pop()
end

return clip_component
