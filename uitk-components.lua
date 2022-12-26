local class = require "love-ui.class"
local clamp = require "love-math.clamp"
local max = math.max


------------------------------------------------------------

--[=[
------------------------------------------------------------


------------------------------------------------------------


------------------------------------------------------------


------------------------------------------------------------

mesh_component = class()
function mesh_component_new(mesh_x, mesh_y, matrix, pivot_x, pivot_y, lines)
	return mesh_component.new {
		mesh_x = mesh_x,
		mesh_y = mesh_y,
		lines = lines or 8,
		pivot_x = pivot_x or 0,
		pivot_y = pivot_y or 0,
		matrix = matrix or m33_ident()
	}
end

function mesh_component:draw(ui_rect)
	local m = m33_offsetted(self.matrix, ui_rect:to_world())
	draw_smesh(m, self.mesh_x, self.mesh_y, self.pivot_x, self.pivot_y, self.lines)
end

function mesh_component:set_mesh(mesh_x, mesh_y, lines)
	self.mesh_x, self.mesh_y, self.lines = mesh_x or self.mesh_x,
		mesh_y or self.mesh_y, lines or self.lines
end

------------------------------------------------------------


------------------------------------------------------------


------------------------------------------------------------


------------------------------------------------------------



------------------------------------------------------------


]=]