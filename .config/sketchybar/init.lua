package.cpath = package.cpath
    .. ";" .. os.getenv("HOME") .. "/.local/share/sketchybar_lua/?.so"
package.path = package.path
    .. ";" .. os.getenv("HOME") .. "/.config/sketchybar/?.lua"

local sbar = require("sketchybar")
local colors = require("colors")

sbar.begin_config()

sbar.bar({
    height        = 37,
    position      = "top",
    y_offset      = 0,
    margin        = 0,
    padding_left  = 10,
    padding_right = 10,
    color         = colors.transparent,
    border_width  = 0,
    corner_radius = 0,
    blur_radius   = 0,
    notch_width   = 210,
    sticky        = "on",
    topmost       = "window",
})

sbar.default({
    updates = "when_shown",
    icon = {
        font = { family = "SF Pro", style = "Bold", size = 13.0 },
        color = colors.fg,
        padding_left = 10,
        padding_right = 6,
    },
    label = {
        font = { family = "SF Pro", style = "Semibold", size = 11.0 },
        color = colors.fg,
        padding_left = 6,
        padding_right = 10,
    },
    padding_left = 8,
    padding_right = 8,
    background = { drawing = false },
})

sbar.add("event", "windows_on_spaces")
sbar.add("event", "window_focus")
sbar.add("event", "space_change")
sbar.add("event", "display_change")

require("items.battery")
require("items.clock")

sbar.add("bracket", "right_pill", { "battery", "clock" }, {
    background = {
        color = colors.bar_bg,
        corner_radius = 9,
        height = 28,
        drawing = true,
        padding_left = 6,
        padding_right = 6,
    },
})

require("items.windows")

sbar.hotload(true)
sbar.end_config()
sbar.event_loop()
