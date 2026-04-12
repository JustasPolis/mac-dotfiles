--- Buffer-local keymaps for diff navigation.
--- Re-applied automatically via BufEnter so they survive buffer changes.
local M = {}

---@type integer?
local _augroup = nil

--- Set up keymaps for a single buffer.
--- @param buf number Buffer handle
local function setup_diff_keymaps(buf)
    local diffs = require("diffs")
    local keys = diffs.config.keymaps
    local opts = { buffer = buf, nowait = true }
    vim.keymap.set("n", keys.next_file, diffs.next_file, opts)
    vim.keymap.set("n", keys.prev_file, diffs.prev_file, opts)
    vim.keymap.set("n", keys.next_hunk, diffs.next_hunk, opts)
    vim.keymap.set("n", keys.prev_hunk, diffs.prev_hunk, opts)
    vim.keymap.set("n", keys.close, diffs.close, opts)
end

--- Setup keymaps for current diff buffers and auto-apply on BufEnter.
--- @param state table Plugin state
function M.setup(state)
    for _, buf in ipairs({ state.left_buf, state.right_buf }) do
        if buf and vim.api.nvim_buf_is_valid(buf) then
            setup_diff_keymaps(buf)
        end
    end

    if _augroup then return end
    _augroup = vim.api.nvim_create_augroup("diffs-keymaps", { clear = true })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = _augroup,
        callback = function()
            local diffs = require("diffs")
            local s = diffs.state
            if not s.diff_tabpage or vim.api.nvim_get_current_tabpage() ~= s.diff_tabpage then
                return
            end
            local win = vim.api.nvim_get_current_win()
            if win == s.left_win or win == s.right_win or win == s.tree_win then
                setup_diff_keymaps(vim.api.nvim_get_current_buf())
            end
        end,
    })
end

--- Remove the BufEnter autocmd.
function M.cleanup()
    if _augroup then
        vim.api.nvim_del_augroup_by_id(_augroup)
        _augroup = nil
    end
end

return M
