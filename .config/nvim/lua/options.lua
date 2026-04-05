vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.backup = false
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
vim.opt.fileencoding = "utf-8"                                      -- the encoding written to a file
vim.opt.hlsearch = false                                            -- highlight all matches on previous search pattern
vim.opt.mouse = "a"                                                 -- allow the mouse to be used in neovim
vim.opt.showmode = false                                            -- we don't need to see things like -- INSERT -- anymore
vim.opt.smartcase = true                                            -- smart case
vim.opt.smartindent = true                                          -- make indenting smarter again
vim.opt.splitbelow = true                                           -- force all horizontal splits to go below current window
vim.opt.splitright = true                                           -- force all vertical splits to go to the right of current window
vim.opt.swapfile = false                                            -- creates a swapfile
vim.opt.timeoutlen = 350                                            -- time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.ttimeoutlen = 0                                              -- time to wait for a key code sequence (e.g. Escape)
vim.opt.undofile = true                                             -- enable persistent undo
vim.opt.updatetime = 300                                            -- faster completion (4000ms default)
vim.opt.writebackup = false                                         -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vim.opt.expandtab = true                                            -- convert tabs to spaces
vim.opt.shiftwidth = 4                                              -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4
vim.opt.cursorline = false                                          -- highlight the current line
vim.opt.number = true                                               -- set numbered lines
vim.opt.relativenumber = true                                       -- set relative numbered lines
vim.opt.numberwidth = 4
vim.opt.wrap = false                                                -- display lines as one long line
vim.opt.confirm = false
vim.opt.ignorecase = true
vim.opt.shiftround = true
vim.opt.splitkeep = "screen"
vim.opt.shortmess:append({
    W = true,
    I = true,
    c = true,
    F = true,
    C = true,
    o = true,
    S = true,
    s = true,
    A = true,
})
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "CursorHold" }, {
	command = "checktime",
})
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local path = vim.api.nvim_buf_get_name(args.buf)
		if path == "" or not vim.uv.fs_stat(path) then
			return
		end
		local w = vim.uv.new_fs_event()
		w:start(path, {}, vim.schedule_wrap(function()
			if vim.api.nvim_buf_is_valid(args.buf) then
				vim.api.nvim_buf_call(args.buf, function()
					vim.cmd("checktime")
				end)
			end
		end))
		vim.api.nvim_buf_attach(args.buf, false, {
			on_detach = function()
				w:stop()
				w:close()
			end,
		})
	end,
})
vim.opt.showtabline = 0
vim.opt.smoothscroll = true
vim.opt.fillchars = {
    eob = " ",
}
vim.opt.scrolloff = 4
vim.o.signcolumn = "yes:1"
vim.opt.cmdheight = 0
vim.o.winborder = "single"
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_altv = 1
vim.g.netrw_bufsettings = "noma nomod nu rnu nowrap ro"
vim.g.netrw_browsex_viewer = (vim.fn.has("mac") == 1) and "open" or "xdg-open"
vim.g.netrw_sort_by = "name"             -- name | time | size | ext
vim.g.netrw_sort_direction = "ascending" -- ascending | descending
vim.g.netrw_list_hide = [[\v(^\.\.?$)|(^\.)|(\.swp$)|(\.pyc$)|(\~$)]]
vim.g.netrw_hide = 1
vim.g.netrw_preview = 1
vim.g.netrw_keepdir = 1
vim.g.netrw_fastbrowse = 1

vim.filetype.add({
    extension = {
        h = "objc",
    },
})

vim.opt.diffopt:append("context:99999")
vim.opt.fillchars:append({ diff = " " })
