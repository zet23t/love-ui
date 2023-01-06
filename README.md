# love-uitk

UITK is a retained and component based GUI system. It was originally written for pico-8, which is why the components still reflect this in some ways such as using the 16 colors of pico-8. The Löve2d adapted version extends this somewhat but is still sticking to some limitations, though since components can be used to describe the looks of a ui_rect, it can be easily shaped into something else. One inherent limitation is that this UI does not support rotation or scaling.

## Fundamentals

There are two base classes:

- ui_rect: A rectangle that a UI element describes
- ui_rect_component: A component that can be attached to a ui_rect

By attaching components to a ui_rect, the ui_rect can describe any UI element.

The most common components are:

- rectfill_component: Fills the rectangle of a ui_rect with a specific color
- sprite_component: Draws a sprite in place of the ui_rect
- sprite9_component: Draws a sprite in a typcial 3x3 grid stretched on top of a ui_rect
- text_component: Draws text on a ui_rect

With these components, it is possible to create something that looks like a button

``` lua
local button = ui_rect:new(0,0,100,10, root_ui_rect)
button:add_component(rectfill_component:new(7,1)) -- a white rect with a dark blue border
button:add_component(text_component:new("Hello world"))
```

Components are actually just mere tables with methods that will get called. Certain events cause these to be called, for instance the method "was_released" is called when the mouse was first pressed down on the ui_rect's boundaries and is then released again. We only need to check if the mouse was released when it was over the ui_rect, which can be found out by checking a flag that the event system sets on the ui_rect. What sounds complicated is actually fairly simple:

``` lua
button:add_component({
	was_triggered = function(self, rect) 
		print "hello world"
	end
})
```

There are different groups of methods that get called in certain orders, each handling one of these tasks:

- Updating
  - update(component, ui_rect): called on update
- Drawing
  - pre_draw(component, ui_rect): called before drawing the ui_rect and its children (used for setting drawing states such as scissor rectangles)
  - draw(component, ui_rect): called during drawing
  - post_draw(component, ui_rect): called after drawing the ui_rect and its children
- Layouting
  - layout_update_size(component, ui_rect): called to let components update the size of the ui_rects. Should be used to do only that
  - layout_update(component, ui_rect): called to let components update size and position of the ui_rects
- Mouse events
  - is_mouse_over(component, ui_rect, mouse_x, mouse_y): called each frame when the mouse is over the element
  - is_pressed_down(component, ui_rect, mouse_x, mouse_y): called each frame when the mouse is being pressed down - but only if this action was started ON that ui_rect and it keeps firing until the mouse button is released, regardless if the mouse is over that component or not
  - mouse_enter(component, ui_rect, mouse_x, mouse_y): called when the mouse enters the component rectangle
  - mouse_exit(component, ui_rect, mouse_x, mouse_y): called when the mouse exits the component rectangle
  - was_pressed_down(component, ui_rect, mouse_x, mouse_y): called once when the mouse is clicked on the element and it was visible, etc.
  - was_released(component, ui_rect, mouse_x, mouse_y): called once when the mouse button was released and only after was_pressed_down was called
  - was_triggered(component, ui_rect, mouse_x, mouse_y): called once when the mouse button was released while being over the component (usually defined as "click")

And this is pretty much everything. Other components and classes do provide utilitary functions, but at the core, the description above pretty much describes the entire concept, which is neatly simply.

## How to use

TODO: insert short documentation how to run uitk