local sbar = require("sketchybar")
local colors = require("colors")
local icon_map = require("icon_map")

local items = {}
local bracket = nil
local last_members_key = ""

local function truncate(s, n)
    if not s or s == "" then return "" end
    if #s <= n then return s end
    return s:sub(1, n) .. "…"
end

local function query_windows()
    local cmd = [[yabai -m query --windows --space 2>/dev/null | jq -r '.[] | [.id, .app, .title, ."has-focus"] | @tsv']]
    local handle = io.popen(cmd)
    if not handle then return "" end
    local out = handle:read("*a") or ""
    handle:close()
    return out
end

local function logf(fmt, ...)
    local f = io.open("/tmp/sketchybar-debug.log", "a")
    if f then
        f:write(os.date("%H:%M:%S") .. " " .. string.format(fmt, ...) .. "\n")
        f:close()
    end
end

local function update(env)
    local sender = (env and env.SENDER) or "init"
    local out = query_windows()
    logf("update(%s) yabai=%q", sender, (out or ""):gsub("\n", "|"))
    local windows = {}
    local present = {}

    for line in out:gmatch("[^\n]+") do
        local id_s, app, title, focused = line:match("^([^\t]+)\t([^\t]*)\t([^\t]*)\t([^\t]*)$")
        local id = tonumber(id_s)
        if id then
            present[id] = true
            table.insert(windows, {
                id = id,
                app = app or "",
                title = title or "",
                focused = focused == "true",
            })
        end
    end

    for wid, item in pairs(items) do
        if not present[wid] then
            sbar.remove(item)
            items[wid] = nil
        end
    end

    local member_names = {}
    for _, w in ipairs(windows) do
        local name = "window." .. w.id
        table.insert(member_names, name)

        local item = items[w.id]
        if not item then
            item = sbar.add("item", name, {
                position = "left",
                click_script = "yabai -m window --focus " .. w.id,
                icon = {
                    font = { family = "sketchybar-app-font", style = "Regular", size = 14.0 },
                    padding_left = 8,
                    padding_right = 4,
                },
                label = {
                    padding_left = 4,
                    padding_right = 8,
                },
            })
            items[w.id] = item
        end

        local glyph = icon_map[w.app] or ":default:"
        local label = w.title ~= "" and w.title or w.app
        label = truncate(label, 22)

        item:set({
            icon  = { string = glyph, color = w.focused and colors.accent or colors.dimmed },
            label = { string = label, color = w.focused and colors.fg     or colors.dimmed },
        })
    end

    local key = table.concat(member_names, ",")
    if key ~= last_members_key then
        logf("  bracket: %q -> %q", last_members_key, key)
        if bracket then sbar.remove(bracket) end
        if #member_names > 0 then
            bracket = sbar.add("bracket", "left_pill", member_names, {
                background = {
                    color = colors.bar_bg,
                    corner_radius = 9,
                    height = 28,
                    drawing = true,
                    padding_left = 6,
                    padding_right = 6,
                },
            })
        else
            bracket = nil
        end
        last_members_key = key
    else
        logf("  bracket unchanged: %q", key)
    end
end

local manager = sbar.add("item", "windows_manager", {
    position = "left",
    updates = "on",
    width = 0,
    padding_left = 0,
    padding_right = 0,
    icon = { drawing = false },
    label = { drawing = false },
    background = { drawing = false },
})

manager:subscribe("space_change",        update)
manager:subscribe("window_focus",        update)
manager:subscribe("windows_on_spaces",   update)
manager:subscribe("front_app_switched",  update)
manager:subscribe("forced",              update)

update()

return manager
