---@class difftree.git
local M = {}

---@class difftree.FileEntry
---@field status string Single char: M, A, D, R, etc.
---@field path string Relative path from git root

---@class difftree.Hunk
---@field old_start integer
---@field old_count integer
---@field new_start integer
---@field new_count integer
---@field change_start integer First actually changed line in the new file
---@field change_end integer Last actually changed line in the new file
---@field preview string First changed line, trimmed

---@type string?
local _git_root = nil

---@return string?
function M.git_root()
    if not _git_root then
        _git_root = vim.fs.root(0, { ".git" })
    end
    return _git_root
end

--- Parse a diff range string into left and right refs.
--- "main..feature" → "main", "feature", ".."
--- "main...feature" → "main", "feature", "..."
--- "HEAD~3" → "HEAD~3", nil, nil
--- nil or "" → nil, nil, nil
---@param range string?
---@return string? left, string? right, string? mode
function M.parse_diff_range(range)
    if not range or range == "" then
        return nil, nil, nil
    end

    local left, right = range:match("^(.+)%.%.%.(.+)$")
    if left then
        return left, right, "..."
    end

    left, right = range:match("^(.+)%.%.(.+)$")
    if left then
        return left, right, ".."
    end

    return range, nil, nil
end

---@param left string?
---@param right string?
---@return string?
function M.get_merge_base(left, right)
    local root = M.git_root()
    if not root or not left or not right then
        return nil
    end

    local result = vim.system({ "git", "merge-base", left, right }, { text = true, cwd = root }):wait()
    if result.code ~= 0 or not result.stdout then
        return nil
    end

    return result.stdout:match("([^\n]+)")
end


--- Parse a full unified diff into files and their hunks in one pass.
--- Replaces the need for separate --name-status + per-file diff calls.
---@param diff_output string Raw stdout from git diff
---@return difftree.FileEntry[] files, table<string, difftree.Hunk[]> hunks_by_file
function M.parse_full_diff(diff_output)
    local files = {} ---@type difftree.FileEntry[]
    local hunks_by_file = {} ---@type table<string, difftree.Hunk[]>
    local lines = vim.split(diff_output, "\n")

    local current_path = nil ---@type string?
    local current_status = "M" ---@type string
    local current_file = nil ---@type difftree.FileEntry?
    for _, line in ipairs(lines) do
        -- New file header
        local a_path, b_path = line:match("^diff %-%-git a/(.+) b/(.+)$")
        if a_path then
            current_path = b_path
            current_status = "M"
            current_file = { status = current_status, path = current_path }
            table.insert(files, current_file)
            hunks_by_file[current_path] = hunks_by_file[current_path] or {}
        elseif line:match("^new file") then
            current_status = "A"
            if current_file then
                current_file.status = current_status
            end
        elseif line:match("^deleted file") then
            current_status = "D"
            if current_file then
                current_file.status = current_status
            end
        elseif line:match("^rename from") then
            current_status = "R"
            if current_file then
                current_file.status = current_status
            end
        elseif current_path then
            -- Hunk header
            local old_start, old_count, new_start, new_count =
                line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
            if old_start then
                local ns = tonumber(new_start)
                local nc = new_count ~= "" and tonumber(new_count) or 1

                table.insert(hunks_by_file[current_path], {
                    old_start = tonumber(old_start),
                    old_count = old_count ~= "" and tonumber(old_count) or 1,
                    new_start = ns,
                    new_count = nc,
                    change_start = ns,
                    change_end = ns + math.max(nc, 1) - 1,
                    preview = "",
                })
            end
        end
    end

    -- Handle files with no hunks (binary, etc.) that had a diff header but no @@
    -- These are registered on the diff header with an empty hunk list.

    return files, hunks_by_file
end

--- Get all changed files and their hunks in a single git call.
--- Uses -U0 (no context) so @@ headers give exact change ranges.
---@param left string? Left ref
---@param right string? Right ref
---@param mode string? ".." or "..."
---@return difftree.FileEntry[] files, table<string, difftree.Hunk[]> hunks_by_file
function M.get_all(left, right, mode)
    local root = M.git_root()
    if not root then
        return {}, {}
    end

    local cmd = { "git", "diff", "-U0" }
    if left and right then
        table.insert(cmd, left .. ((mode == "...") and "..." or "..") .. right)
    elseif left then
        table.insert(cmd, left)
    end
    local result = vim.system(cmd, { text = true, cwd = root }):wait()
    if result.code ~= 0 or not result.stdout then
        return {}, {}
    end
    return M.parse_full_diff(result.stdout)
end

--- Get file content at a specific ref.
---@param filepath string Relative path from git root
---@param ref string? Git ref (nil uses the index)
---@return string? content nil if file doesn't exist at ref
function M.get_content_at_ref(filepath, ref)
    local root = M.git_root()
    if not root then
        return nil
    end

    local show_ref = ref and (ref .. ":" .. filepath) or (":" .. filepath)
    local result = vim.system({ "git", "show", show_ref }, { text = true, cwd = root }):wait()
    if result.code ~= 0 then
        return nil
    end
    return result.stdout
end

return M
