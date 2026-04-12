--- Difftastic side-by-side diff viewer for Neovim.
--- Uses the `difft` CLI (async via vim.system) instead of a native library.
---@diagnostic disable: param-type-mismatch
local M = {}

local diff = require("diffs.diff")
local tree = require("diffs.tree")
local highlight = require("diffs.highlight")
local keymaps = require("diffs.keymaps")

---@class DiffsConfig
---@field highlight_mode string
---@field hunk_wrap_file boolean
---@field scroll_to_first_hunk boolean
---@field keymaps table<string, string>

--- Default configuration
---@type DiffsConfig
M.config = {
    highlight_mode = "treesitter",
    hunk_wrap_file = true,
    scroll_to_first_hunk = true,
    keymaps = {
        next_file = "<leader>nf",
        prev_file = "<leader>pf",
        next_hunk = "<leader>nh",
        prev_hunk = "<leader>ph",
        close = "q",
        select = "<CR>",
    },
}

---@class DiffsState
---@field current_file_idx integer
---@field files table[]
---@field tree_win integer?
---@field tree_buf integer?
---@field left_win integer?
---@field left_buf integer?
---@field right_win integer?
---@field right_buf integer?
---@field original_tabpage integer?
---@field diff_tabpage integer?

--- Current diff state
---@type DiffsState
M.state = {
    current_file_idx = 1,
    files = {},
    tree_win = nil,
    tree_buf = nil,
    left_win = nil,
    left_buf = nil,
    right_win = nil,
    right_buf = nil,
    original_tabpage = nil,
    diff_tabpage = nil,
}

local function split_content(content)
    local lines = vim.split(content or "", "\n", { plain = true })
    if #lines > 0 and lines[#lines] == "" then
        table.remove(lines)
    end
    return lines
end

local function build_diff_args(range)
    local args = {}
    if range == "--staged" then
        args[#args + 1] = "--staged"
    elseif range then
        for _, part in ipairs(vim.split(range, "%s+", { trimempty = true })) do
            args[#args + 1] = part
        end
    end
    return args
end

local function is_zero_oid(oid)
    return oid == nil or oid == "" or oid:match("^0+$") ~= nil
end

local function read_blob(git_root, oid)
    if is_zero_oid(oid) then
        return ""
    end

    local obj = vim.system({ "git", "cat-file", "-p", oid }, { cwd = git_root, text = true }):wait(5000)
    return (obj.code == 0 and obj.stdout) or ""
end

local function read_worktree_file(git_root, path)
    local abs_path = vim.fs.joinpath(git_root, path)
    local ok, lines = pcall(vim.fn.readfile, abs_path, "b")
    if not ok then
        return ""
    end
    return table.concat(lines, "\n")
end

local function detect_right_source(git_root, diff_args)
    local has_cached = false
    for _, arg in ipairs(diff_args) do
        if arg == "--staged" or arg == "--cached" then
            has_cached = true
            break
        end
    end

    local cmd = { "git", "rev-parse", "--revs-only" }
    vim.list_extend(cmd, diff_args)

    local obj = vim.system(cmd, { cwd = git_root, text = true }):wait(5000)
    local revs = {}
    if obj.code == 0 then
        revs = vim.split(vim.trim(obj.stdout or ""), "\n", { trimempty = true })
    end

    if #revs >= 2 then
        return "commit"
    end
    if has_cached then
        return "index"
    end
    return "worktree"
end

local function get_raw_entries(git_root, diff_args)
    local cmd = { "git", "diff", "--raw", "-z" }
    vim.list_extend(cmd, diff_args)

    local obj = vim.system(cmd, { cwd = git_root, text = true }):wait(5000)
    if obj.code ~= 0 or not obj.stdout or obj.stdout == "" then
        return {}
    end

    local entries = {}
    local parts = vim.split(obj.stdout, "\0", { plain = true })
    local i = 1

    while i <= #parts do
        local header = parts[i]
        i = i + 1
        if not header or header == "" then
            break
        end

        local fields = vim.split(header, " ", { trimempty = true })
        local old_oid = fields[3]
        local new_oid = fields[4]
        local status = fields[5] or ""

        local old_path = parts[i]
        i = i + 1
        if not old_path or old_path == "" then
            break
        end

        local entry = {
            old_oid = old_oid,
            new_oid = new_oid,
            status = status,
            old_path = old_path,
            new_path = old_path,
        }

        if status:match("^[RC]") then
            entry.new_path = parts[i] or old_path
            i = i + 1
        end

        entries[entry.old_path] = entry
        entries[entry.new_path] = entry
    end

    return entries
end

local function get_file_contents(git_root, path, entry, right_source)
    if not entry then
        local new_content = right_source == "worktree" and read_worktree_file(git_root, path) or ""
        return "", new_content
    end

    local old_content = read_blob(git_root, entry.old_oid)
    local new_content = ""

    if right_source == "worktree" and is_zero_oid(entry.new_oid) then
        new_content = read_worktree_file(git_root, entry.new_path or path)
    else
        new_content = read_blob(git_root, entry.new_oid)
    end

    return old_content, new_content
end

--- Transform difft CLI JSON into the rows format expected by diff.render().
---@param data table Parsed JSON object from difft --display json
---@param old_content string Content of the old file version
---@param new_content string Content of the new file version
---@return table File data with path, language, rows, hunk_starts
local function transform_file(data, old_content, new_content)
    local old_lines = split_content(old_content)
    local new_lines = split_content(new_content)

    -- Build highlight lookup from chunks: line_number (0-idx) → {{start, end}}
    local left_hl = {}
    local right_hl = {}
    for _, chunk in ipairs(data.chunks or {}) do
        for _, entry in ipairs(chunk) do
            if entry.lhs then
                local n = entry.lhs.line_number
                left_hl[n] = left_hl[n] or {}
                for _, c in ipairs(entry.lhs.changes) do
                    left_hl[n][#left_hl[n] + 1] = { start = c.start, ["end"] = c["end"] }
                end
            end
            if entry.rhs then
                local n = entry.rhs.line_number
                right_hl[n] = right_hl[n] or {}
                for _, c in ipairs(entry.rhs.changes) do
                    right_hl[n][#right_hl[n] + 1] = { start = c.start, ["end"] = c["end"] }
                end
            end
        end
    end

    -- Build rows from aligned_lines
    local rows = {}
    local old_to_row = {}
    local new_to_row = {}

    for i, pair in ipairs(data.aligned_lines or {}) do
        local old_idx = pair[1]
        local new_idx = pair[2]
        local old_nil = old_idx == vim.NIL
        local new_nil = new_idx == vim.NIL

        rows[#rows + 1] = {
            left = {
                content = old_nil and "" or (old_lines[old_idx + 1] or ""),
                is_filler = old_nil,
                highlights = old_nil and {} or (left_hl[old_idx] or {}),
            },
            right = {
                content = new_nil and "" or (new_lines[new_idx + 1] or ""),
                is_filler = new_nil,
                highlights = new_nil and {} or (right_hl[new_idx] or {}),
            },
        }

        if not old_nil then old_to_row[old_idx] = i end
        if not new_nil then new_to_row[new_idx] = i end
    end

    -- Derive hunk_starts (0-indexed row positions) from the first entry of each chunk
    local hunk_starts = {}
    for _, chunk in ipairs(data.chunks or {}) do
        if #chunk > 0 then
            local first = chunk[1]
            local row_idx = (first.lhs and old_to_row[first.lhs.line_number])
                or (first.rhs and new_to_row[first.rhs.line_number])
            if row_idx then
                hunk_starts[#hunk_starts + 1] = row_idx - 1
            end
        end
    end

    return {
        path = data.path,
        language = data.language,
        rows = rows,
        hunk_starts = hunk_starts,
    }
end

--- Initialize the plugin with user options.
--- @param opts table|nil User configuration
function M.setup(opts)
    opts = opts or {}

    if opts.highlight_mode then
        M.config.highlight_mode = opts.highlight_mode
    end
    if opts.hunk_wrap_file ~= nil then
        M.config.hunk_wrap_file = opts.hunk_wrap_file
    end
    if opts.scroll_to_first_hunk ~= nil then
        M.config.scroll_to_first_hunk = opts.scroll_to_first_hunk
    end
    if opts.keymaps then
        for k, v in pairs(opts.keymaps) do
            M.config.keymaps[k] = v
        end
    end
    highlight.setup(opts.highlights)
end

--- Open diff view for a git commit range (blocking with 5s timeout).
--- @param range string|nil Git range (nil = unstaged, "--staged" = staged)
function M.open(range)
    if M.state.tree_win or M.state.left_win or M.state.right_win then
        M.close()
    end

    if vim.fn.executable("difft") ~= 1 then
        vim.notify("difft (difftastic) not found in PATH", vim.log.levels.ERROR)
        return
    end

    local original_tabpage = vim.api.nvim_get_current_tabpage()
    local git_root = vim.fs.root(0, ".git") or vim.uv.cwd()
    local diff_args = build_diff_args(range)
    local right_source = detect_right_source(git_root, diff_args)
    local raw_entries = get_raw_entries(git_root, diff_args)

    local cmd = {
        "env", "DFT_UNSTABLE=yes",
        "GIT_EXTERNAL_DIFF=difft --display json --context 9999",
        "git", "diff",
    }
    vim.list_extend(cmd, diff_args)

    local obj = vim.system(cmd, { cwd = git_root, text = true }):wait(5000)
    if obj.signal ~= 0 then
        vim.notify("Diff timed out", vim.log.levels.WARN)
        return
    end

    local stdout = obj.stdout or ""
    if stdout == "" then return end

    local json_lines = vim.split(vim.trim(stdout), "\n", { trimempty = true })
    local parsed = {}
    for _, line in ipairs(json_lines) do
        local ok, data = pcall(vim.json.decode, line)
        if ok and data.aligned_lines and #data.aligned_lines > 0 then
            parsed[#parsed + 1] = data
        end
    end

    if #parsed == 0 then return end

    -- All data ready — open the UI.
    M.state.original_tabpage = original_tabpage
    vim.cmd("tabnew")
    M.state.diff_tabpage = vim.api.nvim_get_current_tabpage()

    M.state.files = {}
    for i, pf in ipairs(parsed) do
        local old_content, new_content = get_file_contents(git_root, pf.path, raw_entries[pf.path], right_source)
        M.state.files[i] = transform_file(pf, old_content, new_content)
    end
    M.state.current_file_idx = 1

    tree.open(M.state)
    diff.open(M.state)
    keymaps.setup(M.state)

    local first_idx = tree.first_file_in_display_order()
    if first_idx then
        M.show_file(first_idx)
    end
end

--- Close the diff view.
function M.close()
    local diff_tabpage = M.state.diff_tabpage
    local original_tabpage = M.state.original_tabpage

    tree.close()
    diff.cleanup()
    keymaps.cleanup()

    M.state = {
        current_file_idx = 1,
        files = {},
        tree_win = nil,
        tree_buf = nil,
        left_win = nil,
        left_buf = nil,
        right_win = nil,
        right_buf = nil,
        original_tabpage = nil,
        diff_tabpage = nil,
    }

    if original_tabpage and vim.api.nvim_tabpage_is_valid(original_tabpage) then
        vim.api.nvim_set_current_tabpage(original_tabpage)
    end

    if diff_tabpage and vim.api.nvim_tabpage_is_valid(diff_tabpage) then
        local tabnr = vim.api.nvim_tabpage_get_number(diff_tabpage)
        vim.cmd("tabclose " .. tabnr)
    end
end

--- Show a specific file by index.
--- @param idx integer File index (1-based)
--- @param skip_hunk_jump boolean? Skip auto-jump to first hunk
function M.show_file(idx, skip_hunk_jump)
    if idx < 1 or idx > #M.state.files then
        return
    end
    M.state.current_file_idx = idx
    diff.render(M.state, M.state.files[idx])
    keymaps.setup(M.state)
    if not skip_hunk_jump and M.config.scroll_to_first_hunk then
        diff.first_hunk(M.state)
    end
    tree.highlight_current(M.state)
end

--- @param idx integer
--- @param hunk_fn function
local function show_file_and_jump_to_hunk(idx, hunk_fn)
    M.show_file(idx, true)
    vim.schedule(function()
        hunk_fn(M.state)
    end)
end

function M.next_file()
    local next_idx = tree.next_file_in_display_order(M.state.current_file_idx)
    if next_idx then
        M.show_file(next_idx)
        return
    end

    local first_idx = tree.first_file_in_display_order()
    if first_idx and first_idx ~= M.state.current_file_idx then
        M.show_file(first_idx)
    end
end

function M.prev_file()
    local prev_idx = tree.prev_file_in_display_order(M.state.current_file_idx)
    if prev_idx then
        M.show_file(prev_idx)
        return
    end

    local last_idx = tree.last_file_in_display_order()
    if last_idx and last_idx ~= M.state.current_file_idx then
        M.show_file(last_idx)
    end
end

function M.next_hunk()
    local jumped = diff.next_hunk(M.state)
    if not jumped then
        if M.config.hunk_wrap_file then
            local next_idx = tree.next_file_in_display_order(M.state.current_file_idx)
            if next_idx then
                show_file_and_jump_to_hunk(next_idx, diff.first_hunk)
            else
                local first_idx = tree.first_file_in_display_order()
                if first_idx and first_idx ~= M.state.current_file_idx then
                    show_file_and_jump_to_hunk(first_idx, diff.first_hunk)
                end
            end
        else
            diff.first_hunk(M.state)
        end
    end
    vim.cmd("normal! zz")
end

function M.prev_hunk()
    local jumped = diff.prev_hunk(M.state)
    if not jumped then
        if M.config.hunk_wrap_file then
            local prev_idx = tree.prev_file_in_display_order(M.state.current_file_idx)
            if prev_idx then
                show_file_and_jump_to_hunk(prev_idx, diff.last_hunk)
            else
                local last_idx = tree.last_file_in_display_order()
                if last_idx and last_idx ~= M.state.current_file_idx then
                    show_file_and_jump_to_hunk(last_idx, diff.last_hunk)
                end
            end
        else
            diff.last_hunk(M.state)
        end
    end
    vim.cmd("normal! zz")
end


return M
