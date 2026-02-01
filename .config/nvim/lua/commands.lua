local function augroup(name)
	return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		vim.cmd("tabdo wincmd =")
		vim.opt.statusline = string.rep("─", vim.api.nvim_win_get_width(0))
	end,
})

local function poke_change(bufnr)
	if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].modifiable == false then
		return
	end
	local view = vim.fn.winsaveview()
	local line = vim.api.nvim_get_current_line()
	vim.api.nvim_set_current_line(line .. " ")
	vim.cmd("silent undo")
	vim.fn.winrestview(view)
end

-- Hack to force semantic tokens to load for Swift files, need to make file change
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.swift",
	callback = function(args)
		vim.defer_fn(function()
			poke_change(args.buf)
			vim.api.nvim_del_autocmd(args.id)
		end, 1000)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "python", "rust", "swift", "zig", "c", "cpp", "objc", "objcpp" },
	callback = function(args)
		vim.treesitter.start(args.buf)
	end,
})

vim.keymap.set("n", "<leader>m", function()
	local items = { "Build", "Test", "Deploy" }
	vim.ui.select(items, { prompt = "Choose task" }, function(choice)
		if choice == "Build" then
			vim.cmd("make")
		end
		if choice == "Test" then
			vim.cmd("Make test")
		end
		if choice == "Deploy" then
			print("Deploying…")
		end
	end)
end)

local function toggle_diag_virtual_text()
	local cfg = vim.diagnostic.config()
	local vt = cfg.virtual_text
	local enabled = (vt == true) or (type(vt) == "table")
	vim.diagnostic.config({ virtual_text = not enabled })
end

vim.api.nvim_create_user_command("ToggleDiagVirtualText", toggle_diag_virtual_text, {})
vim.keymap.set("n", "<leader>td", toggle_diag_virtual_text, { desc = "Toggle diagnostics virtual text" })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			Snacks.picker.files()
		end
	end,
})

-- OpenCode in Kitty tab
local function opencode_in_kitty(opts)
	opts = opts or {}
	local cwd = vim.fn.getcwd()
	local cmd = {
		"kitten",
		"@",
		"launch",
		"--type=tab",
		"--tab-title=opencode",
		"--cwd=" .. cwd,
		"opencode",
	}

	-- If text is provided, use 'run' subcommand with the text as prompt
	if opts.text and opts.text ~= "" then
		table.insert(cmd, "run")
		table.insert(cmd, opts.text)
	end

	vim.fn.jobstart(cmd, { detach = true })
end

-- Get visual selection text
local function get_visual_selection()
	local _, ls, cs = unpack(vim.fn.getpos("'<"))
	local _, le, ce = unpack(vim.fn.getpos("'>"))
	local lines = vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
	return table.concat(lines, "\n")
end

-- Normal mode: open opencode
vim.keymap.set("n", "<leader>oo", function()
	opencode_in_kitty()
end, { desc = "Open opencode in Kitty tab" })

-- Visual mode: send selection to opencode
vim.keymap.set("v", "<leader>oo", function()
	local text = get_visual_selection()
	opencode_in_kitty({ text = text })
end, { desc = "Send selection to opencode in Kitty tab" })

-- Normal mode: prompt for text and send to opencode
vim.keymap.set("n", "<leader>op", function()
	vim.ui.input({ prompt = "OpenCode prompt: " }, function(input)
		if input and input ~= "" then
			opencode_in_kitty({ text = input })
		end
	end)
end, { desc = "Prompt and send to opencode in Kitty tab" })
