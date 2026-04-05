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

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "lua",
        "python",
        "markdown",
        "markdown_inline",
        "rust",
        "swift",
        "zig",
        "c",
        "cpp",
        "objc",
        "objcpp",
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },
    callback = function(args)
        if vim.bo[args.buf].buftype == "" then
            vim.treesitter.start(args.buf)
        end
    end,
})

local function toggle_diag_virtual_text()
    local cfg = vim.diagnostic.config()
    local vt = cfg.virtual_text
    local enabled = (vt == true) or (type(vt) == "table")
    vim.diagnostic.config({ virtual_text = not enabled })
end

vim.api.nvim_create_user_command("ToggleDiagVirtualText", toggle_diag_virtual_text, {})
vim.keymap.set("n", "<leader>td", toggle_diag_virtual_text, { desc = "Toggle diagnostics virtual text" })

-- Get visual selection text
local function get_visual_selection()
    local _, ls, cs = unpack(vim.fn.getpos("'<"))
    local _, le, ce = unpack(vim.fn.getpos("'>"))
    local lines = vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
    return table.concat(lines, "\n")
end
