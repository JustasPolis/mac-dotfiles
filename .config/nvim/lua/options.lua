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
vim.opt.shiftwidth = 4 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4 -- insert 2 spaces for a tab
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
vim.opt.smoothscroll = true
vim.opt.fillchars = {
	eob = " ",
}
vim.opt.scrolloff = 4
vim.o.signcolumn = "yes:1"
vim.opt.autoindent = true
vim.opt.cmdheight = 0

vim.cmd([[highlight StatusLine guibg=NONE]])

vim.api.nvim_set_hl(0, "Normal", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "TelescopePreviewDirectory", { bg = "none", fg = "NvimLightRed" })
vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none", fg = "NvimLightGrey4" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none", fg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "NvimLightGrey4" })
vim.api.nvim_set_hl(0, "Pmenu", { bg = "none", fg = "NvimLightGrey4" })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "none", fg = "NvimLightBlue" })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "NvimLightGrey4", fg = "NvimLightGrey4" })
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "NvimLightGrey4", fg = "NvimLightGrey4" })
vim.api.nvim_set_hl(0, "@lsp.type.struct", { bg = "none", fg = "#dfd1fb" })
vim.api.nvim_set_hl(0, "@lsp.type", { bg = "none", fg = "#92d3e3" })
vim.api.nvim_set_hl(0, "@lsp.type.keyword", { bg = "none", fg = "#dd93b6" })
vim.api.nvim_set_hl(0, "@lsp.type.string", { bg = "none", fg = "#dd977f" })
vim.api.nvim_set_hl(0, "@lsp.type.method", { bg = "none", fg = "#92d3e3" })
vim.api.nvim_set_hl(0, "@lsp.type.function", { bg = "none", fg = "#92d3e3" })
vim.api.nvim_set_hl(0, "@lsp.type.decorator", { bg = "none", fg = "#dfd1fb" })
vim.api.nvim_set_hl(0, "@lsp.type.modifier", { bg = "none", fg = "#dfd1fb" })
vim.api.nvim_set_hl(0, "@variable", { bg = "none", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "@variable.member", { bg = "none", fg = "#6DD9FF" })
vim.api.nvim_set_hl(0, "@type.swift", { bg = "none", fg = "#dfd1fb" })
vim.api.nvim_set_hl(0, "@type.definition", { bg = "none", fg = "#dfd1fb" })
vim.api.nvim_set_hl(0, "@keyword.type", { bg = "none", fg = "#dd93b6" })
vim.api.nvim_set_hl(0, "@keyword.modifier", { bg = "none", fg = "#dd93b6" })
vim.api.nvim_set_hl(0, "@variable.builtin", { bg = "none", fg = "#dd93b6" })
vim.api.nvim_set_hl(0, "@keyword", { bg = "none", fg = "#dd93b6" })
vim.api.nvim_set_hl(0, "@attribute", { bg = "none", fg = "#dfd1fb" })
vim.api.nvim_set_hl(0, "@string", { bg = "none", fg = "#dd977f" })
vim.api.nvim_set_hl(0, "@constructor", { bg = "none", fg = "#dd93b6" })
vim.api.nvim_set_hl(0, "@function.method", { bg = "none", fg = "#6DD9FF" })
vim.api.nvim_set_hl(0, "@function.call", { bg = "none", fg = "#6DD9FF" })
vim.api.nvim_set_hl(0, "SnippetTabStop", { bg = "none", fg = "none" })
vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { bg = "none", fg = "none" })
vim.o.winborder = "single"
local u = function(name, sp)
	vim.api.nvim_set_hl(0, name, { undercurl = true, sp = sp, fg = nil, bg = nil, bold = false, italic = false })
end
u("DiagnosticUnderlineError", "#ff5555")
u("DiagnosticUnderlineWarn", "#ffaa00")
u("DiagnosticUnderlineInfo", "#00aaff")
u("DiagnosticUnderlineHint", "#66ccff")

vim.diagnostic.config({
	virtual_text = false,
	underline = true,
	update_in_insert = true,
	severity_sort = true,
	float = {
		border = "single",
		source = true,
		focusable = true,
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚",
			[vim.diagnostic.severity.WARN] = "󰀪",
			[vim.diagnostic.severity.INFO] = "󰋽",
			[vim.diagnostic.severity.HINT] = "󰌶",
		},
	},
})
vim.highlight.priorities.semantic_tokens = 95
