local sbar = require("sketchybar")
local colors = require("colors")

local clock = sbar.add("item", "clock", {
    position = "right",
    update_freq = 10,
    padding_right = 2,
    icon = { drawing = false },
    label = {
        color = colors.fg,
        padding_right = 4,
    },
})

clock:subscribe({ "routine", "forced" }, function()
    clock:set({ label = os.date("%a %d %b  %H:%M") })
end)

return clock
