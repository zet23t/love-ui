local cursor_normal = { id = 1, offset_x = -1, offset_y = -1 }
local cursor_resize = { id = 17, offset_x = -4, offset_y = -4 }
local cursor_horizontal = { id = 49, offset_x = -8, offset_y = -8 }
local cursor_hidden = { id = -1 }
local cursor = cursor_normal

local cursors = {
	cursor_normal = cursor_normal;
	cursor_resize = cursor_resize;
	cursor_hidden = cursor_hidden;
	cursor_horizontal = cursor_horizontal;
}

return cursors