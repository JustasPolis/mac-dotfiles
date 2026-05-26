local sbar = require("sketchybar")
local colors = require("colors")

local battery = sbar.add("item", "battery", {
    position = "right",
    update_freq = 30,
    padding_left = 2,
    icon = { padding_left = 4 },
})

local function update()
    sbar.exec("pmset -g batt", function(out)
        local percent = tonumber(out:match("(%d+)%%"))
        local charging = out:find("AC Power") ~= nil

        if not percent then
            battery:set({
                icon = { string = "\u{1006EA}", color = colors.dimmed },
                label = { drawing = false },
            })
            return
        end

        local icon, color
        if charging then
            icon = "\u{10088B}"
            color = colors.secondary
        else
            if     percent >= 90 then icon = "\u{1006E8}"
            elseif percent >= 60 then icon = "\u{100EB8}"
            elseif percent >= 30 then icon = "\u{100EB6}"
            elseif percent >= 10 then icon = "\u{1006E9}"
            else                      icon = "\u{1006EA}" end

            if percent < 20 then color = colors.accent
            else                  color = colors.muted end
        end

        battery:set({
            icon  = { string = icon, color = color },
            label = { string = percent .. "%", drawing = true },
        })
    end)
end

battery:subscribe({ "routine", "system_woke", "power_source_change", "forced" }, update)

return battery
