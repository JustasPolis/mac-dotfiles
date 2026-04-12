vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.backup = false
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
vim.opt.fileencoding = "utf-8"
vim.opt.hlsearch = false
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.timeoutlen = 350
vim.opt.ttimeoutlen = 0
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.writebackup = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.cursorline = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
vim.opt.wrap = false
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
vim.g.netrw_sort_by = "name"
vim.g.netrw_sort_direction = "ascending"
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
