vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end

local p = {
	none = "none",
	cyan = "#6DD9FF",
	pink = "#dd93b6",
	purple = "#dfd1fb",
	orange = "#dd977f",
	white = "#ffffff",
	grey = "#9b9ea4",
}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

--   hl("Normal",      { fg=p.fg, bg=p.bg })
--   hl("NormalFloat", { fg=p.fg, bg=p.bg })
--   hl("CursorLine",  { bg=p.gray })
--   hl("ColorColumn", { bg=p.gray })
--   hl("LineNr",      { fg=p.dim })
--   hl("CursorLineNr",{ fg=p.yellow })
--   hl("VertSplit",   { fg=p.gray })
--   hl("StatusLine",  { fg=p.fg, bg=p.gray })
--   hl("Pmenu",       { fg=p.fg, bg=p.gray })
--   hl("PmenuSel",    { fg=p.bg, bg=p.blue })
--
--   -- Syntax (Vim)
--   hl("Comment",     { fg=p.dim, italic=true })
--   hl("Constant",    { fg=p.cyan })
--   hl("String",      { fg=p.green })
--   hl("Character",   { fg=p.green })
--   hl("Number",      { fg=p.yellow })
--   hl("Boolean",     { fg=p.yellow })
--   hl("Identifier",  { fg=p.fg })
--   hl("Function",    { fg=p.blue })
--   hl("Statement",   { fg=p.mag })
--   hl("Conditional", { fg=p.mag })
--   hl("Repeat",      { fg=p.mag })
--   hl("Operator",    { fg=p.fg })
--   hl("Type",        { fg=p.yellow })
--   hl("PreProc",     { fg=p.mag })
--   hl("Special",     { fg=p.cyan })
--   hl("Todo",        { fg=p.bg, bg=p.yellow, bold=true })
--
--   hl("@comment",         { link="Comment" })
--   hl("@string",          { link="String" })
--   hl("@number",          { link="Number" })
--   hl("@boolean",         { link="Boolean" })
--   hl("@function",        { link="Function" })
--   hl("@function.builtin",{ fg=p.blue, bold=true })
--   hl("@type",            { link="Type" })
--   hl("@keyword",         { link="Statement" })
--   hl("@operator",        { link="Operator" })
--   hl("@variable",        { fg=p.fg })
--   hl("@variable.builtin",{ fg=p.mag, italic=true })

vim.cmd([[highlight StatusLine guibg=NONE]])

hl("Normal", { bg = "none", ctermbg = "none" })
hl("NormalNC", { bg = "none", ctermbg = "none" })
hl("TelescopeBorder", { bg = "none", fg = p.grey })
hl("NormalFloat", { bg = "none", fg = "none" })
hl("FloatBorder", { bg = "none", fg = p.grey })
hl("Pmenu", { bg = "none", fg = p.grey })
hl("PmenuSel", { bg = "none", fg = p.cyan })
hl("PmenuThumb", { bg = p.grey, fg = p.grey })
hl("PmenuSbar", { bg = p.grey, fg = p.grey })
hl("@lsp.type.struct", { bg = "none", fg = p.pink })
hl("@lsp.type", { bg = "none", fg = p.cyan })
hl("@lsp.type.keyword", { bg = "none", fg = p.pink })
hl("@lsp.type.string", { bg = "none", fg = p.orange })
hl("@lsp.type.method", { bg = "none", fg = p.cyan })
hl("@lsp.type.function", { bg = "none", fg = p.cyan })
hl("@lsp.type.decorator", { bg = "none", fg = p.purple })
hl("@lsp.type.modifier", { bg = p.none, fg = p.purple })
hl("@variable", { bg = p.none, fg = p.white })
hl("@variable.member", { bg = p.none, fg = p.cyan })
hl("@type.swift", { bg = p.none, fg = p.purple })
hl("@type.definition", { bg = p.none, fg = p.purple })
hl("@keyword.type", { bg = p.none, fg = p.pink })
hl("@keyword.modifier", { bg = p.none, fg = p.pink })
hl("@variable.builtin", { bg = p.none, fg = p.pink })
hl("@keyword", { bg = p.none, fg = p.pink })
hl("@attribute", { bg = p.none, fg = p.purple })
hl("@string", { bg = p.none, fg = p.orange })
hl("@constructor", { bg = p.none, fg = p.pink })
hl("@function.method", { bg = p.none, fg = p.cyan })
hl("@function.call", { bg = p.none, fg = p.cyan })
hl("SnippetTabStop", { bg = p.none, fg = p.none })
hl("DiagnosticUnnecessary", { bg = p.none, fg = p.none })
hl("@lsp.type.function.swift", { bg = p.none, fg = p.white })
hl("@punctuation.bracket.lua", { bg = p.none, fg = p.white })
hl("@constructor.lua", { bg = p.none, fg = p.white })
