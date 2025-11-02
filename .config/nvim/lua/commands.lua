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
