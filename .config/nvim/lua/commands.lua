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
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	pattern = "*.swift",
	callback = function(args)
		vim.defer_fn(function()
			poke_change(args.buf)
			vim.api.nvim_del_autocmd(args.id)
		end, 400)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "python", "rust", "swift" }, -- pick filetypes
	callback = function(args)
		vim.treesitter.start(args.buf)
	end,
})
