---@class difftree.view
local M = {}

local git = require("difftree.git")

---@class difftree.view.State
---@field base_win integer?
---@field right_win integer?
---@field active_file string?

---@type difftree.view.State
local state = {
    base_win = nil,
    right_win = nil,
    active_file = nil,
}

---@type integer
local _buf_counter = 0

--- Create a scratch buffer with file content at a ref.
---@param content string? File content, nil for new/nonexistent files
---@param filepath string Used to derive buffer name and filetype
---@param ref string Label for the buffer name (e.g. "HEAD", "main", "abc123")
---@return integer bufnr
function M.create_base_buf(content, filepath, ref)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"

    if content and content ~= "" then
        local lines = vim.split(content, "\n")
        if lines[#lines] == "" then
            table.remove(lines)
        end
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end

    vim.bo[buf].modifiable = false

    -- Unique name to avoid collisions when reopening same file
    _buf_counter = _buf_counter + 1
    vim.api.nvim_buf_set_name(buf, "difftree://" .. ref .. "/" .. filepath .. "#" .. _buf_counter)

    local ft = vim.filetype.match({ filename = filepath })
    if ft then
        vim.bo[buf].filetype = ft
    end

    return buf
end

--- Check if a diff view is currently open.
---@return boolean
function M.is_open()
    return state.base_win ~= nil and vim.api.nvim_win_is_valid(state.base_win)
end

--- Set the diff window pair. Called by init.lua after creating the layout.
---@param base_win integer Left diff window
---@param right_win integer Right diff window
function M.set_windows(base_win, right_win)
    state.base_win = base_win
    state.right_win = right_win
end

--- Load a file's diff into the existing window pair.
--- Old scratch buffers auto-wipe via bufhidden=wipe when replaced.
---@param filepath string Relative path from git root
---@param target_line integer? Line number to jump to
---@param left_ref string? Git ref for left side (nil = index)
---@param right_ref string? Git ref for right side (nil = working tree)
---@param mode string? ".." or "..."
function M.open(filepath, target_line, left_ref, right_ref, mode)
    local root = git.git_root()
    if not root then
        return
    end

    if not state.base_win or not vim.api.nvim_win_is_valid(state.base_win) then
        return
    end
    if not state.right_win or not vim.api.nvim_win_is_valid(state.right_win) then
        return
    end

    -- Turn off diff mode before swapping buffers
    vim.api.nvim_win_call(state.base_win, function()
        vim.cmd("diffoff")
    end)
    vim.api.nvim_win_call(state.right_win, function()
        vim.cmd("diffoff")
    end)

    if right_ref then
        local base_ref = left_ref
        if mode == "..." then
            base_ref = git.get_merge_base(left_ref, right_ref) or left_ref
        end

        local left_content = git.get_content_at_ref(filepath, right_ref)
        local left_buf = M.create_base_buf(left_content, filepath, right_ref)
        vim.api.nvim_win_set_buf(state.base_win, left_buf)

        local right_content = git.get_content_at_ref(filepath, base_ref)
        local right_buf = M.create_base_buf(right_content, filepath, base_ref or "index")
        vim.api.nvim_win_set_buf(state.right_win, right_buf)
    else
        -- Working-tree diffs keep the editable file open on the left.
        local abs_path = root .. "/" .. filepath
        vim.api.nvim_set_current_win(state.base_win)
        vim.cmd("edit " .. vim.fn.fnameescape(abs_path))

        local right_content = git.get_content_at_ref(filepath, left_ref)
        local right_buf = M.create_base_buf(right_content, filepath, left_ref or "index")
        vim.api.nvim_win_set_buf(state.right_win, right_buf)
    end

    -- Enable diff mode, disable folding
    vim.api.nvim_win_call(state.base_win, function()
        vim.cmd("diffthis")
        vim.wo.foldenable = false
    end)
    vim.api.nvim_win_call(state.right_win, function()
        vim.cmd("diffthis")
        vim.wo.foldenable = false
    end)

    -- Jump to target line in left window (current version)
    vim.api.nvim_set_current_win(state.base_win)
    if target_line then
        local buf = vim.api.nvim_win_get_buf(state.base_win)
        local line_count = vim.api.nvim_buf_line_count(buf)
        local line = math.max(1, math.min(target_line, line_count))
        vim.api.nvim_win_set_cursor(state.base_win, { line, 0 })
        vim.cmd("normal! zz")
    end

    state.active_file = filepath
end

--- Close the diff view — diffoff and clear state, don't close windows.
function M.close()
    if state.base_win and vim.api.nvim_win_is_valid(state.base_win) then
        vim.api.nvim_win_call(state.base_win, function()
            vim.cmd("diffoff")
        end)
    end
    if state.right_win and vim.api.nvim_win_is_valid(state.right_win) then
        vim.api.nvim_win_call(state.right_win, function()
            vim.cmd("diffoff")
        end)
    end

    state.base_win = nil
    state.right_win = nil
    state.active_file = nil
end

return M
