-- Save the original layout function so we can still use its logic
local old_layout = Tab.layout

-- 1. Disable the Status bar drawing
Status.redraw = function()
	return {}
end

-- 2. Expand the Tab area to fill the space left by the status bar
Tab.layout = function(self, ...)
	self._area = ui.Rect({
		x = self._area.x,
		y = self._area.y,
		w = self._area.w,
		h = self._area.h + 1,
	})
	return old_layout(self, ...)
end
