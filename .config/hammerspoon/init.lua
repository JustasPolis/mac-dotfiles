local function pressFn(mods, key)
	if key == nil then
		key = mods
		mods = {}
	end

	return function()
		hs.eventtap.keyStroke(mods, key, 1000)
	end
end

local function remap(mods, key, pressFn)
	hs.hotkey.bind(mods, key, pressFn, nil, pressFn)
end

function mapCmdTab(event)
	local flags = event:getFlags()
	local chars = event:getCharacters()
	if chars == "\t" and flags:containExactly({ "cmd" }) then
		os.execute("open -g raycast://extensions/justinpolis/applications/open-app")
		return true
	elseif chars == string.char(25) and flags:containExactly({ "cmd", "shift" }) then
		return true
	elseif chars == "\t" and flags:containExactly({ "cmd", "shift" }) then
		return true
	end
end

tapCmdTab = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, mapCmdTab)
tapCmdTab:start()

remap({ "ctrl" }, "n", pressFn("down"))
remap({ "ctrl" }, "p", pressFn("up"))
remap({ "ctrl" }, "f", pressFn("right"))
remap({ "ctrl" }, "b", pressFn("left"))

local function createNewSpace()
	local currentScreen = hs.screen.mainScreen()
	hs.spaces.addSpaceToScreen(currentScreen, true)
end

local function yabai(commands)
	for _, cmd in ipairs(commands) do
		os.execute("/opt/homebrew/bin/yabai -m " .. cmd)
	end
end

hs.loadSpoon("RecursiveBinder")

spoon.RecursiveBinder.escapeKey = { {}, "escape" } -- Press escape to abort
spoon.RecursiveBinder.showBindHelper = false

local singleKey = spoon.RecursiveBinder.singleKey

local keyMap = {
	[singleKey("m", "move")] = {
		[singleKey("e", "empty")] = function()
			createNewSpace()
			local focusedWindow = hs.window.focusedWindow()
			local spaces = hs.spaces.allSpaces()
			local uuid = focusedWindow:screen():getUUID() -- uuid for current screen
			local spaceIDs = spaces[uuid]
			yabai({ "window --space " .. #spaceIDs })
		end,
	},
	[singleKey("a", "apps")] = {
		[singleKey("t", "terminal")] = function()
			os.execute("open /Applications/kitty.app")
		end,
		[singleKey("b", "browser")] = function()
			hs.application.launchOrFocus("Arc")
		end,
		[singleKey("x", "xcode")] = function()
			hs.application.launchOrFocus("/System/Volumes/Data/Applications/Xcode-15.3.0.app/")
		end,
	},
	[singleKey("r", "raycast")] = {
		[singleKey("m", "menu items")] = function()
			os.execute("open -g raycast://extensions/raycast/navigation/search-menu-items")
		end,
	},
	[singleKey("f", "focus")] = {
		[singleKey("l", "right")] = function()
			yabai({ "window --focus east" })
		end,
		[singleKey("h", "left")] = function()
			yabai({ "window --focus west" })
		end,
		[singleKey("k", "top")] = function()
			yabai({ "window --focus north" })
		end,
		[singleKey("j", "bottom")] = function()
			yabai({ "window --focus south" })
		end,
	},
	[singleKey("y", "focus")] = {
		[singleKey("r", "resize")] = {
			[singleKey("h", "half")] = function()
				yabai({ "window --ratio abs:0.5" })
			end,
			[singleKey("q", "q")] = function()
				yabai({ "window --ratio abs:0.77" })
			end,
		},
	},
	[singleKey("b", "browser")] = {
		[singleKey("t", "tab")] = {
			[singleKey("n", "next")] = function()
				hs.eventtap.keyStroke({ "alt", "cmd" }, "down", 200)
			end,
			[singleKey("p", "previous")] = function()
				hs.eventtap.keyStroke({ "alt", "cmd" }, "up", 200)
			end,
		},
	},
	[singleKey("x", "xcode")] = {
		[singleKey("f", "focus")] = {
			[singleKey("n", "next")] = function()
				local xcode = hs.application.get("Xcode")
				hs.eventtap.keyStroke({ "alt", "cmd" }, "`", 200, xcode)
			end,
		},
		[singleKey("s", "show")] = {
			[singleKey("a", "actions")] = function()
				local xcode = hs.application.get("Xcode")
				hs.eventtap.keyStroke({ "shift", "cmd" }, "A", 200, xcode)
			end,
		},
		[singleKey("t", "tabs")] = {
			[singleKey("n", "next tab")] = function()
				hs.eventtap.keyStroke({ "shift", "cmd" }, "]")
			end,
			[singleKey("p", "previous tab")] = function()
				hs.eventtap.keyStroke({ "shift", "cmd" }, "[")
			end,
		},
		[singleKey("g", "goto")] = {
			[singleKey("d", "jump to definition")] = function()
				hs.eventtap.keyStroke({ "ctrl", "cmd" }, "J")
			end,
			[singleKey("b", "go back")] = function()
				hs.eventtap.keyStroke({ "ctrl", "cmd" }, "left")
			end,
			[singleKey("f", "go forward")] = function()
				hs.eventtap.keyStroke({ "ctrl", "cmd" }, "right")
			end,
		},
		[singleKey("c", "command")] = {
			[singleKey("r", "run")] = function()
				local xcode = hs.application.get("Xcode")
				hs.eventtap.keyStroke({ "cmd" }, "R", 200, xcode)
			end,
			[singleKey("s", "save")] = function()
				local xcode = hs.application.get("Xcode")
				hs.eventtap.keyStroke({ "cmd" }, "S", 200, xcode)
			end,
			[singleKey("f", "format")] = function()
				local xcode = hs.application.get("Xcode")
				hs.eventtap.keyStroke({ "ctrl" }, "I", 200, xcode)
			end,
			[singleKey("t", "test")] = function()
				local xcode = hs.application.get("Xcode")
				hs.eventtap.keyStroke({ "ctrl", "alt", "cmd" }, "U", 200, xcode)
			end,
		},
		[singleKey("d", "debug")] = {
			[singleKey("t", "toggle")] = function()
				local xcode = hs.application.get("Xcode")
				hs.eventtap.keyStroke({ "shift", "cmd" }, "Y", 200, xcode)
			end,
		},
		[singleKey("n", "navigator")] = {
			[singleKey("p", "projects")] = function()
				local xcode = hs.application.get("Xcode")
				hs.eventtap.keyStroke({ "cmd" }, "1", 200, xcode)
			end,
			[singleKey("t", "toggle")] = function()
				local xcode = hs.application.get("Xcode")
				hs.eventtap.keyStroke({ "alt", "shift" }, "B", xcode)
			end,
		},
	},
}

hs.hotkey.bind({}, "F18", spoon.RecursiveBinder.recursiveBind(keyMap))

local spaceItem = hs.menubar.new(true, "spaceItem")

local spaces = hs.spaces.allSpaces()
local uuid = hs.screen.mainScreen():getUUID()
local spaceIDs = spaces[uuid]
for i, v in ipairs(spaceIDs) do
	if v == hs.spaces.focusedSpace() then
		spaceItem:setTitle("Space:" .. i)
	end
end

hs.spaces.watcher
	.new(function(s)
		local spaces = hs.spaces.allSpaces()
		local uuid = hs.screen.mainScreen():getUUID()
		local spaceIDs = spaces[uuid]
		for i, v in ipairs(spaceIDs) do
			if v == hs.spaces.focusedSpace() then
				spaceItem:setTitle("Space:" .. i)
			end
		end
	end)
	:start()

hs.ipc = require("hs.ipc")
hs.ipc.cliInstall("/opt/homebrew/bin")

-- this version can *only* be used if invoked from within a coroutine
function getYabaiWindowsFromWithinCoroutine()
	if not coroutine.isyieldable() then
		error("this function cannot be invoked on the main Lua thread")
	end

	local taskIsDone = false
	local output
	local task = hs.task.new("/opt/homebrew/bin/yabai", function(_, stdOut, stdErr)
		output = stdOut
		taskIsDone = true
	end, { "-m", "query", "--windows" })
	task:start()

	-- this code waits until the flag taskIsDone is set, but requires this function to only
	-- be invoked from within a coroutine
	while not taskIsDone do
		coroutine.applicationYield()
	end
	return output
end

local function getApps()
	if not coroutine.isyieldable() then
		error("this function cannot be invoked on the main Lua thread")
	end

	local userAppsTaskIsDone = false
	local systemAppsTaskIsDone = false
	local userAppsTaskOutput
	local systemAppsTaskOutput
	local userAppsTask = hs.task.new("/usr/bin/mdfind", function(_, stdOut, stdErr)
		userAppsTaskOutput = stdOut
		userAppsTaskIsDone = true
	end, { "kMDItemKind = 'Application'", "-onlyin", "/Applications" })
	userAppsTask:start()

	local systemAppsTask = hs.task.new("/usr/bin/mdfind", function(_, stdOut, stdErr)
		systemAppsTaskOutput = stdOut
		systemAppsTaskIsDone = true
	end, { "kMDItemKind = 'Application'", "-onlyin", "/System/Applications" })
	systemAppsTask:start()

	while not userAppsTaskIsDone do
		coroutine.applicationYield()
	end

	while not systemAppsTaskIsDone do
		coroutine.applicationYield()
	end

	return userAppsTaskOutput .. systemAppsTaskOutput
end

local function makeActionACoroutine()
	coroutine.wrap(function()
		local yOutput = getYabaiWindowsFromWithinCoroutine()
		local yJson = hs.json.decode(yOutput)
		for i, v in ipairs(yJson) do
			print(v.id, v.app, v.title)
		end
	end)()
end

local function profileFunction(func, ...)
	local startTime = hs.timer.secondsSinceEpoch()
	local result = { func(...) }
	local endTime = hs.timer.secondsSinceEpoch()
	print(string.format("Execution time: %.6f seconds", endTime - startTime))
	return table.unpack(result)
end

function getAppsCoroutine()
	coroutine.wrap(function()
		local apps = getApps()
		local appsModified = {}
		for appPath in apps:gmatch("([^\n]*)\n?") do
			if appPath ~= "" then
				local appName = appPath:match(".*/(.-)%.app")
				appsModified[appName] = { isRunning = false, path = appPath }
			end
		end

		for i, v in pairs(appsModified) do
			print(i, v)
		end
	end)()
end

getAppsCoroutine()

local running_apps = hs.application.runningApplications()

-- for index, val in pairs(running_apps) do
--   print(val:path())
-- end
