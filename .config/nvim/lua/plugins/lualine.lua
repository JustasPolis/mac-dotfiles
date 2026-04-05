local p = require("theme").palette
local theme = require("lualine.themes.auto")
theme.normal.c.bg = "None"
theme.inactive.c.bg = "None"
theme.visual.c.bg = "None"
theme.insert.c.bg = "None"
theme.replace.c.bg = "None"
theme.command.c.bg = "None"

local file_type = function()
    if vim.bo.filetype == "Trouble" then
        return false
    elseif vim.bo.filetype == "NvimTree" then
        return false
    elseif vim.api.nvim_win_get_config(0).relative == "win" then
        return false
    elseif vim.api.nvim_win_get_config(0).relative == "editor" then
        return false
    else
        return true
    end
end

local function hide_in_filetypes(ft_list)
    return function()
        return not vim.tbl_contains(ft_list, vim.bo.filetype)
    end
end

local active_lsp_name = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if next(clients) ~= nil then
        return clients[1].name
    end
    return ""
end

local function agent_cond()
    return vim.b.agent and vim.g.agent_status ~= nil
end

local function agent_model()
    local s = vim.g.agent_status
    return s and s.model or ""
end

local function agent_thinking()
    local s = vim.g.agent_status
    if s and s.reasoning and s.thinking then
        return s.thinking
    end
    return ""
end

local function agent_mode()
    local s = vim.g.agent_status
    return s and s.mode or ""
end

local function agent_context()
    local s = vim.g.agent_status
    if s and s.context_pct then
        return math.floor(s.context_pct) .. "%%"
    end
    return ""
end

local function agent_context_color()
    local s = vim.g.agent_status
    local pct = s and s.context_pct or 0
    if pct > 80 then
        return { fg = p.accent, bg = "None" }
    elseif pct > 60 then
        return { fg = p.muted, bg = "None" }
    else
        return { fg = p.fg, bg = "None" }
    end
end

require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = theme,
        ignore_focus = { "help", "NetrwTreeListing", "difftree" },
        always_divide_middle = false,
        globalstatus = true,
        refresh = {
            statusline = 1000,
        },
        disabled_filetypes = {
            statusline = { "alpha", "fish" },
            winbar = {},
        },
    },
    sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {
            {
                agent_mode,
                cond = function() return agent_cond() and agent_mode() ~= "" end,
                color = { fg = p.secondary, bg = "None" },
                padding = { left = 0, right = 1 },
            },
            {
                agent_model,
                cond = agent_cond,
                color = { fg = p.muted, bg = "None" },
                padding = { left = 0, right = 1 },
            },
            {
                agent_thinking,
                cond = function() return agent_cond() and agent_thinking() ~= "" end,
                color = { fg = p.accent, bg = "None" },
                padding = { left = 0, right = 1 },
            },
            {
                agent_context,
                cond = function() return agent_cond() and agent_context() ~= "" end,
                color = agent_context_color,
                padding = { left = 0, right = 0 },
            },
            {
                "diagnostics",
                draw_empty = false,
                separator = " ",
                always_visible = false,
                color = { fg = "None", bg = "None" },
                sections = { "error", "warn", "info", "hint" },
                cond = file_type,
                padding = {
                    left = 0,
                    right = 0,
                },
            },
            {
                active_lsp_name,
                always_visible = false,
                color = { fg = p.fg, bg = "None" },
                cond = hide_in_filetypes({ "netrw", "Telescope" }),
            },
            {
                "filetype",
                icon_only = true,
                separator = "",
                cond = function() return file_type() and not vim.b.agent end,
                padding = { left = 0, right = 1 },
                color = { fg = "None", bg = "None" },
            },
            {
                "filename",
                path = 0,
                cond = function() return file_type() and not vim.b.agent end,
                symbols = { modified = "", readonly = "", unnamed = "" },
                padding = { left = 0, right = 0 },
                color = { fg = p.fg, bg = "None" },
            },
        },
        lualine_z = {
            {
                "branch",
                always_visible = true,
                icon = { " ", padding = { left = 0, right = 0 }, color = { fg = p.accent } },
                color = { fg = p.fg, bg = "None" },
            },
        },
    },
})
