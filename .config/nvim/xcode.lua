-- Xcode MCP Bridge client for Neovim
local M = {}

M.job_id = nil
M.request_id = 0
M.callbacks = {}
M.initialized = false

-- JSON encode/decode using vim.json
local json = vim.json

function M.start()
	if M.job_id then
		print("MCP bridge already running")
		return
	end

	M.job_id = vim.fn.jobstart({ "xcrun", "mcpbridge" }, {
		on_stdout = function(_, data, _)
			for _, line in ipairs(data) do
				if line and line ~= "" then
					M.handle_response(line)
				end
			end
		end,
		on_stderr = function(_, data, _)
			for _, line in ipairs(data) do
				if line and line ~= "" then
					print("[MCP stderr] " .. line)
				end
			end
		end,
		on_exit = function(_, code, _)
			print("[MCP] Process exited with code: " .. code)
			M.job_id = nil
			M.initialized = false
			M.callbacks = {}
		end,
		stdin = "pipe",
		stdout_buffered = false,
	})

	if M.job_id <= 0 then
		print("Failed to start mcpbridge")
		M.job_id = nil
		return
	end

	print("[MCP] Started mcpbridge, job_id: " .. M.job_id)

	-- Send initialize
	M.send_request("initialize", {
		protocolVersion = "2024-11-05",
		capabilities = {},
		clientInfo = { name = "neovim", version = "1.0" },
	}, function(result)
		print("[MCP] Initialized: " .. vim.inspect(result))
		M.send_notification("notifications/initialized")
		M.initialized = true
		print("[MCP] Ready!")
	end)
end

function M.stop()
	if M.job_id then
		vim.fn.jobstop(M.job_id)
		M.job_id = nil
		M.initialized = false
		print("[MCP] Stopped")
	end
end

function M.send_request(method, params, callback)
	if not M.job_id then
		print("MCP bridge not running. Call M.start() first")
		return
	end

	M.request_id = M.request_id + 1
	local id = M.request_id

	local request = {
		jsonrpc = "2.0",
		id = id,
		method = method,
		params = params or {},
	}

	local msg = json.encode(request) .. "\n"
	vim.fn.chansend(M.job_id, msg)
	print("[MCP ->] " .. method .. " (id: " .. id .. ")")
	if callback then
		M.callbacks[id] = callback
	end
end

function M.send_notification(method, params)
	if not M.job_id then
		print("MCP bridge not running")
		return
	end

	local notification = {
		jsonrpc = "2.0",
		method = method,
	}
	-- Only add params if provided and not empty
	if params and next(params) then
		notification.params = params
	end

	local msg = json.encode(notification) .. "\n"
	print("[MCP ->] notification: " .. method)
	vim.fn.chansend(M.job_id, msg)
end

function M.handle_response(line)
	local ok, response = pcall(json.decode, line)
	if not ok then
		print("[MCP] Failed to parse: " .. line)
		return
	end

	print("[MCP <-] " .. vim.inspect(response))

	if response.id and M.callbacks[response.id] then
		local cb = M.callbacks[response.id]
		M.callbacks[response.id] = nil
		if response.error then
			print("[MCP Error] " .. vim.inspect(response.error))
		else
			cb(response.result)
		end
	end
end

-- Manual init - for debugging
function M.send_init()
	M.send_request("initialize", {
		protocolVersion = "2024-11-05",
		capabilities = {},
		clientInfo = { name = "neovim", version = "1.0" },
	}, function(result)
		print("[MCP] Initialize response: " .. vim.inspect(result))
	end)
end

function M.send_initialized()
	M.send_notification("notifications/initialized")
	M.initialized = true
end

-- Convenience functions

function M.list_tools()
	M.send_request("tools/list", {}, function(result)
		print("\n=== Available Tools ===")
		if result and result.tools then
			for _, tool in ipairs(result.tools) do
				print("  - " .. tool.name)
			end
		end
	end)
end

function M.list_windows()
	M.send_request("tools/call", {
		name = "XcodeListWindows",
		arguments = {},
	}, function(result)
		print("\n=== Xcode Windows ===")
		print(vim.inspect(result))
	end)
end

function M.build(tab_id)
	tab_id = tab_id or "windowtab3"
	M.send_request("tools/call", {
		name = "BuildProject",
		arguments = { tabIdentifier = tab_id },
	}, function(result)
		print("\n=== Build Result ===")
		print(vim.inspect(result))
	end)
end

function M.call_tool(name, args)
	args = args or {}
	M.send_request("tools/call", {
		name = name,
		arguments = args,
	}, function(result)
		print("\n=== " .. name .. " Result ===")
		print(vim.inspect(result))
	end)
end

return M
