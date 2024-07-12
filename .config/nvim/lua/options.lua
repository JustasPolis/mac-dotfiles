vim.opt.backup = false
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" } -- mostly just for cmp
vim.opt.fileencoding = "utf-8" -- the encoding written to a file
vim.opt.hlsearch = false -- highlight all matches on previous search pattern
vim.opt.mouse = "a" -- allow the mouse to be used in neovim
vim.opt.showmode = false -- we don't need to see things like -- INSERT -- anymore
vim.opt.smartcase = true -- smart case
vim.opt.smartindent = true -- make indenting smarter again
vim.opt.splitbelow = true -- force all horizontal splits to go below current window
vim.opt.splitright = true -- force all vertical splits to go to the right of current window
vim.opt.swapfile = false -- creates a swapfile
vim.opt.termguicolors = true -- set term gui colors (most terminals support this)
vim.opt.timeoutlen = 350 -- time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.undofile = true -- enable persistent undo
vim.opt.updatetime = 300 -- faster completion (4000ms default)
vim.opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.shiftwidth = 2 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 2 -- insert 2 spaces for a tab
vim.opt.cursorline = false -- highlight the current line
vim.opt.number = true -- set numbered lines
vim.opt.relativenumber = true -- set relative numbered lines
vim.opt.numberwidth = 4 -- set number column width to 2 {default 4}
vim.opt.wrap = false -- display lines as one long line
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
vim.opt.showcmd = false
vim.opt.laststatus = 0
vim.opt.statusline = string.rep("─", vim.api.nvim_win_get_width(0))
vim.opt.smoothscroll = true
vim.opt.fillchars = {
  eob = " ",
}
vim.opt.cmdheight = 0
vim.opt.scrolloff = 4
vim.o.signcolumn = "yes:1"
vim.opt.autoindent = true

vim.cmd([[highlight StatusLine guibg=NONE]])
vim.diagnostic.config({
  underline = true,
})

vim.diagnostic.config({ virtual_text = { prefix = "", spacing = 0 } })

local signs = { Error = "", Warn = "󱈸", Hint = "", Info = "󰙎" }
for name, icon in pairs(signs) do
  name = "DiagnosticSign" .. name
  vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
end
