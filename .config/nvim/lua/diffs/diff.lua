--- Side-by-side diff display with synchronized scrolling.
--- Uses virtual lines for alignment so buffers contain clean source code.
---@diagnostic disable: param-type-mismatch, assign-type-mismatch
local M = {}

--- Ensure treesitter is attached for a buffer/filetype.
--- @param buf integer
--- @param ft string
local function ensure_treesitter(buf, ft)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    if not pcall(vim.treesitter.language.add, ft) then
        return
    end

    if vim.bo[buf].filetype ~= ft then
        vim.bo[buf].filetype = ft
    end

    pcall(vim.treesitter.start, buf, ft)
end

--- Line positions where hunks start (1-indexed), per side
--- @type number[]
M.left_hunk_positions = {}
--- @type number[]
M.right_hunk_positions = {}

--- Scroll sync state
---@type integer?
M._sync_augroup = nil
M._syncing = false
---@type table?
M._sync_map = nil

--- Maps difftastic language names to Vim filetypes
local FILETYPES = {
    Rust = "rust",
    Lua = "lua",
    TOML = "toml",
    JSON = "json",
    JavaScript = "javascript",
    TypeScript = "typescript",
    Python = "python",
    Go = "go",
    C = "c",
    ["C++"] = "cpp",
    Java = "java",
    Ruby = "ruby",
    Shell = "sh",
    Bash = "bash",
    Markdown = "markdown",
    YAML = "yaml",
    HTML = "html",
    CSS = "css",
    Clojure = "clojure",
    Swift = "swift",
}

--- Safely set cursor, clamping to buffer line count.
--- @param win integer
--- @param pos integer[]
local function safe_set_cursor(win, pos)
    if not vim.api.nvim_win_is_valid(win) then return end
    local buf = vim.api.nvim_win_get_buf(win)
    local max = vim.api.nvim_buf_line_count(buf)
    pos[1] = math.max(1, math.min(pos[1], max))
    vim.api.nvim_win_set_cursor(win, pos)
end

--- Set buffer options for a scratch diff buffer.
--- @param buf integer Buffer handle
local function setup_diff_buffer(buf)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
end

--- Resolve the filetype for a diff entry.
--- @param file table
--- @return string?
local function resolve_filetype(file)
    return FILETYPES[file.language] or vim.filetype.match({ filename = file.path })
end


--- Set window options for diff windows (no scrollbind — we do manual sync).
--- @param win integer Window handle
local function setup_diff_window(win)
    vim.wo[win].scrollbind = false
    vim.wo[win].cursorbind = false
    vim.wo[win].number = true
    vim.wo[win].signcolumn = "no"
end

--- Find the corresponding line on the other side given a visual position.
--- @param visual number Visual row to find
--- @param cum_fillers number[] Cumulative filler counts for the target side
--- @param count number Total real lines on the target side
--- @return number Real line number (1-indexed)
local function visual_to_line(visual, cum_fillers, count)
    local best = 1
    for i = 1, count do
        local v = i + (cum_fillers[i] or 0)
        if v <= visual then
            best = i
        else
            break
        end
    end
    return best
end

--- Set up scroll sync between left and right panes.
--- @param state table Plugin state
local function setup_scroll_sync(state)
    if M._sync_augroup then
        vim.api.nvim_del_augroup_by_id(M._sync_augroup)
    end

    M._sync_augroup = vim.api.nvim_create_augroup("diffs-scroll-sync", { clear = true })

    vim.api.nvim_create_autocmd("WinScrolled", {
        group = M._sync_augroup,
        callback = function()
            if M._syncing or not M._sync_map then
                return
            end
            M._syncing = true

            local map = M._sync_map
            local current = vim.api.nvim_get_current_win()

            pcall(function()
                if current == state.left_win and vim.api.nvim_win_is_valid(state.right_win) then
                    local info = vim.fn.getwininfo(state.left_win)[1]
                    local topline = info and info.topline or 1
                    local visual = topline + (map.left_cum[topline] or 0)
                    local target = visual_to_line(visual, map.right_cum, map.right_count)
                    vim.api.nvim_win_call(state.right_win, function()
                        vim.fn.winrestview({ topline = target })
                    end)
                elseif current == state.right_win and vim.api.nvim_win_is_valid(state.left_win) then
                    local info = vim.fn.getwininfo(state.right_win)[1]
                    local topline = info and info.topline or 1
                    local visual = topline + (map.right_cum[topline] or 0)
                    local target = visual_to_line(visual, map.left_cum, map.left_count)
                    vim.api.nvim_win_call(state.left_win, function()
                        vim.fn.winrestview({ topline = target })
                    end)
                end
            end)

            M._syncing = false
        end,
    })
end

function M.cleanup()
    if M._sync_augroup then
        vim.api.nvim_del_augroup_by_id(M._sync_augroup)
        M._sync_augroup = nil
    end
    M._sync_map = nil
    M._syncing = false
    M.left_hunk_positions = {}
    M.right_hunk_positions = {}
end

--- Open the side-by-side diff panes.
--- @param state table Plugin state
function M.open(state)
    -- Move to the window above the bottom tree panel
    vim.cmd("wincmd k")

    -- Current window becomes left diff pane (scratch, old version)
    state.left_win = vim.api.nvim_get_current_win()
    state.left_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(state.left_win, state.left_buf)
    setup_diff_buffer(state.left_buf)

    -- Create right diff pane (scratch, new version)
    vim.cmd("vsplit")
    state.right_win = vim.api.nvim_get_current_win()
    state.right_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(state.right_win, state.right_buf)
    setup_diff_buffer(state.right_buf)

    setup_diff_window(state.left_win)
    setup_diff_window(state.right_win)
end

--- Render a file's diff content into the left/right panes.
--- @param state table Plugin state
--- @param file table File data with rows, hunk_starts, language
function M.render(state, file)
    local config = require("diffs").config
    local rows = file.rows or {}

    M.left_hunk_positions = {}
    M.right_hunk_positions = {}

    if #rows == 0 then
        vim.bo[state.left_buf].modifiable = true
        vim.bo[state.right_buf].modifiable = true
        vim.api.nvim_buf_set_lines(state.left_buf, 0, -1, false, { "-- Empty --" })
        vim.api.nvim_buf_set_lines(state.right_buf, 0, -1, false, { "-- Empty --" })
        vim.bo[state.left_buf].modifiable = false
        vim.bo[state.right_buf].modifiable = false
        return
    end

    -- Separate real content from filler rows
    local left_lines = {}
    local right_lines = {}
    ---@type table<integer, integer?>
    local row_to_left = {} --- row index -> left real line (1-indexed), nil if filler
    ---@type table<integer, integer?>
    local row_to_right = {} --- row index -> right real line (1-indexed), nil if filler
    local left_fillers_before = {} --- real line -> filler count before it
    local right_fillers_before = {}
    local left_idx, right_idx = 0, 0
    local left_pending, right_pending = 0, 0

    for i, row in ipairs(rows) do
        if row.left.is_filler then
            left_pending = left_pending + 1
        else
            left_idx = left_idx + 1
            left_lines[left_idx] = row.left.content
            left_fillers_before[left_idx] = left_pending
            left_pending = 0
            row_to_left[i] = left_idx
        end

        if row.right.is_filler then
            right_pending = right_pending + 1
        else
            right_idx = right_idx + 1
            right_lines[right_idx] = row.right.content
            right_fillers_before[right_idx] = right_pending
            right_pending = 0
            row_to_right[i] = right_idx
        end
    end

    -- Trailing fillers go below last real line
    local left_trailing = left_pending
    local right_trailing = right_pending

    -- Cumulative filler counts for scroll sync
    local left_cum = {}
    local cum = 0
    for i = 1, #left_lines do
        cum = cum + (left_fillers_before[i] or 0)
        left_cum[i] = cum
    end
    local right_cum = {}
    cum = 0
    for i = 1, #right_lines do
        cum = cum + (right_fillers_before[i] or 0)
        right_cum[i] = cum
    end

    M._sync_map = {
        left_cum = left_cum,
        right_cum = right_cum,
        left_count = #left_lines,
        right_count = #right_lines,
    }

    -- Left buffer: scratch with old content
    vim.bo[state.left_buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.left_buf, 0, -1, false, left_lines)
    vim.bo[state.left_buf].modifiable = false

    vim.bo[state.right_buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.right_buf, 0, -1, false, right_lines)
    vim.bo[state.right_buf].modifiable = false

    local ft = resolve_filetype(file)
    local use_treesitter = config.highlight_mode ~= "difftastic"
    vim.bo[state.left_buf].filetype = ft or ""
    vim.bo[state.right_buf].filetype = ft or ""
    if use_treesitter and ft then
        ensure_treesitter(state.left_buf, ft)
        ensure_treesitter(state.right_buf, ft)
    end

    -- Namespaces for highlights and virtual lines
    local left_ns = vim.api.nvim_create_namespace("diffs-left")
    local right_ns = vim.api.nvim_create_namespace("diffs-right")
    vim.api.nvim_buf_clear_namespace(state.left_buf, left_ns, 0, -1)
    vim.api.nvim_buf_clear_namespace(state.right_buf, right_ns, 0, -1)

    local removed_hl = use_treesitter and "DifftRemoved" or "DifftRemovedFg"
    local added_hl = use_treesitter and "DifftAdded" or "DifftAddedFg"

    -- Apply diff highlights mapped to real line indices
    for i, row in ipairs(rows) do
        local lr = row_to_left[i]
        if lr then
            for _, hl in ipairs(row.left.highlights) do
                vim.api.nvim_buf_set_extmark(state.left_buf, left_ns, lr - 1, hl.start, {
                    end_col = hl["end"],
                    hl_group = removed_hl,
                })
            end
        end

        local rr = row_to_right[i]
        if rr and rr <= vim.api.nvim_buf_line_count(state.right_buf) then
            for _, hl in ipairs(row.right.highlights) do
                pcall(vim.api.nvim_buf_set_extmark, state.right_buf, right_ns, rr - 1, hl.start, {
                    end_col = hl["end"],
                    hl_group = added_hl,
                })
            end
        end
    end

    -- Add virtual filler lines
    local filler_virt = { { string.rep("╱", 300), "DifftFiller" } }

    for real_line, count in pairs(left_fillers_before) do
        if count > 0 then
            local vlines = {}
            for _ = 1, count do
                vlines[#vlines + 1] = filler_virt
            end
            vim.api.nvim_buf_set_extmark(state.left_buf, left_ns, real_line - 1, 0, {
                virt_lines_above = true,
                virt_lines = vlines,
            })
        end
    end
    if left_trailing > 0 and #left_lines > 0 then
        local vlines = {}
        for _ = 1, left_trailing do
            vlines[#vlines + 1] = filler_virt
        end
        vim.api.nvim_buf_set_extmark(state.left_buf, left_ns, #left_lines - 1, 0, {
            virt_lines = vlines,
        })
    end

    local right_buf_lines = vim.api.nvim_buf_line_count(state.right_buf)
    for real_line, count in pairs(right_fillers_before) do
        if count > 0 and real_line <= right_buf_lines then
            local vlines = {}
            for _ = 1, count do
                vlines[#vlines + 1] = filler_virt
            end
            vim.api.nvim_buf_set_extmark(state.right_buf, right_ns, real_line - 1, 0, {
                virt_lines_above = true,
                virt_lines = vlines,
            })
        end
    end
    if right_trailing > 0 and right_buf_lines > 0 then
        local vlines = {}
        for _ = 1, right_trailing do
            vlines[#vlines + 1] = filler_virt
        end
        vim.api.nvim_buf_set_extmark(state.right_buf, right_ns, right_buf_lines - 1, 0, {
            virt_lines = vlines,
        })
    end

    -- Remap hunk positions to real line indices per side
    for _, row_pos in ipairs(file.hunk_starts or {}) do
        local rp = row_pos + 1 -- 1-indexed
        for j = rp, #rows do
            if row_to_left[j] then
                M.left_hunk_positions[#M.left_hunk_positions + 1] = row_to_left[j]
                break
            end
        end
        for j = rp, #rows do
            if row_to_right[j] then
                M.right_hunk_positions[#M.right_hunk_positions + 1] = row_to_right[j]
                break
            end
        end
    end
    -- Set up custom scroll sync
    setup_scroll_sync(state)

    vim.api.nvim_set_current_win(state.right_win)
    safe_set_cursor(state.left_win, { 1, 0 })
    safe_set_cursor(state.right_win, { 1, 0 })
end

--- Get the current diff window (left or right).
--- @param state table Plugin state
--- @return number|nil Window handle or nil if invalid
local function get_diff_win(state)
    local current = vim.api.nvim_get_current_win()
    local win = current == state.right_win and state.right_win or state.left_win
    if win and vim.api.nvim_win_is_valid(win) then
        return win
    end
    return nil
end

--- Get hunk positions for the active window side.
--- @param state table Plugin state
--- @return number[] Hunk positions
local function get_hunk_positions(state)
    local current = vim.api.nvim_get_current_win()
    if current == state.right_win then
        return M.right_hunk_positions
    end
    return M.left_hunk_positions
end

--- Jump to the next hunk.
--- @param state table Plugin state
--- @return boolean True if jumped to a hunk, false if at/past last hunk
function M.next_hunk(state)
    local positions = get_hunk_positions(state)
    if #positions == 0 then
        return false
    end
    local win = get_diff_win(state)
    if not win then
        return false
    end

    local line = vim.api.nvim_win_get_cursor(win)[1]
    for _, pos in ipairs(positions) do
        if pos > line then
            safe_set_cursor(win, { pos, 0 })
            return true
        end
    end
    return false
end

--- Jump to the previous hunk.
--- @param state table Plugin state
--- @return boolean True if jumped to a hunk, false if at/before first hunk
function M.prev_hunk(state)
    local positions = get_hunk_positions(state)
    if #positions == 0 then
        return false
    end
    local win = get_diff_win(state)
    if not win then
        return false
    end

    local line = vim.api.nvim_win_get_cursor(win)[1]
    for i = #positions, 1, -1 do
        if positions[i] < line then
            safe_set_cursor(win, { positions[i], 0 })
            return true
        end
    end
    return false
end

--- Jump to the first hunk.
--- @param state table Plugin state
function M.first_hunk(state)
    local positions = get_hunk_positions(state)
    if #positions == 0 then
        return
    end
    local win = get_diff_win(state)
    if win then
        safe_set_cursor(win, { positions[1], 0 })
    end
end

--- Jump to the last hunk.
--- @param state table Plugin state
function M.last_hunk(state)
    local positions = get_hunk_positions(state)
    if #positions == 0 then
        return
    end
    local win = get_diff_win(state)
    if win then
        safe_set_cursor(win, { positions[#positions], 0 })
    end
end

return M
