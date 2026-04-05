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
--- "main..feature" → "main", "feature"
--- "main...feature" → "main", "feature"
--- "HEAD~3" → "HEAD~3", nil
--- nil or "" → nil, nil
---@param range string?
---@return string? left, string? right
function M.parse_diff_range(range)
    if not range or range == "" then
        return nil, nil
    end

    local left, right = range:match("^(.+)%.%.%.(.+)$")
    if left then
        return left, right
    end

    left, right = range:match("^(.+)%.%.(.+)$")
    if left then
        return left, right
    end

    return range, nil
end

--- Build git diff command from parsed refs.
---@param left string? Left ref (base)
---@param right string? Right ref (nil = working tree)
---@param filepath string? File to diff (nil = all files)
---@param name_status boolean? If true, add --name-status flag
---@return string[]
function M.build_diff_cmd(left, right, filepath, name_status)
    local cmd = { "git", "diff" } ---@type string[]

    if name_status then
        table.insert(cmd, "--name-status")
    end

    if left and right then
        table.insert(cmd, left .. ".." .. right)
    elseif left then
        table.insert(cmd, left)
    end

    if filepath then
        table.insert(cmd, "--")
        table.insert(cmd, filepath)
    end

    return cmd
end

--- Get the base (left-side) ref for git show.
---@param left string?
---@param right string?
---@return string?
function M.resolve_base_ref(left, right)
    if left then
        return left
    end
    return nil
end

--- Get the right-side ref for git show.
---@param left string?
---@param right string?
---@return string?
function M.resolve_right_ref(left, right)
    return right
end

--- Parse `git diff --name-status` output into structured file entries.
---@param output string Raw stdout from git diff --name-status
---@return difftree.FileEntry[]
function M.parse_name_status(output)
    local files = {} ---@type difftree.FileEntry[]
    for line in output:gmatch("[^\n]+") do
        local status, path = line:match("^(%a%d*)%s+(.+)$")
        if status and path then
            status = status:sub(1, 1)
            local rename_path = path:match("\t(.+)$")
            table.insert(files, {
                status = status,
                path = rename_path or path,
            })
        end
    end
    return files
end

--- Parse unified diff output into hunk metadata.
---@param diff_output string Raw stdout from git diff
---@return difftree.Hunk[]
function M.parse_diff_hunks(diff_output)
    local hunks = {} ---@type difftree.Hunk[]
    local lines = vim.split(diff_output, "\n")

    for i, line in ipairs(lines) do
        local old_start, old_count, new_start, new_count =
            line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
        if old_start then
            local preview = ""
            for j = i + 1, math.min(i + 20, #lines) do
                local l = lines[j]
                if l:match("^@@ ") then
                    break
                end
                if l:match("^[%+%-]") and not l:match("^[%+%-][%+%-][%+%-]") then
                    preview = l:sub(2):match("^%s*(.-)%s*$") or ""
                    if #preview > 60 then
                        preview = preview:sub(1, 57) .. "..."
                    end
                    break
                end
            end

            table.insert(hunks, {
                old_start = tonumber(old_start),
                old_count = old_count ~= "" and tonumber(old_count) or 1,
                new_start = tonumber(new_start),
                new_count = new_count ~= "" and tonumber(new_count) or 1,
                preview = preview,
            })
        end
    end
    return hunks
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
    local is_rename = false

    for i, line in ipairs(lines) do
        -- New file header
        local a_path, b_path = line:match("^diff %-%-git a/(.+) b/(.+)$")
        if a_path then
            current_path = b_path
            current_status = "M"
            is_rename = false
        elseif line:match("^new file") then
            current_status = "A"
        elseif line:match("^deleted file") then
            current_status = "D"
        elseif line:match("^rename from") then
            is_rename = true
            current_status = "R"
        elseif current_path then
            -- Hunk header
            local old_start, old_count, new_start, new_count =
                line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
            if old_start then
                -- Register the file on first hunk (or if not yet registered)
                if not hunks_by_file[current_path] then
                    table.insert(files, { status = current_status, path = current_path })
                    hunks_by_file[current_path] = {}
                end

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
    -- They won't appear in the output, which is fine

    return files, hunks_by_file
end

--- Get all changed files and their hunks in a single git call.
--- Uses -U0 (no context) so @@ headers give exact change ranges.
---@param left string? Left ref
---@param right string? Right ref
---@return difftree.FileEntry[] files, table<string, difftree.Hunk[]> hunks_by_file
function M.get_all(left, right)
    local root = M.git_root()
    if not root then
        return {}, {}
    end

    local cmd = M.build_diff_cmd(left, right)
    -- Insert -U0 after "git diff" to strip context lines
    table.insert(cmd, 3, "-U0")
    local result = vim.system(cmd, { text = true, cwd = root }):wait()
    if result.code ~= 0 or not result.stdout then
        return {}, {}
    end
    return M.parse_full_diff(result.stdout)
end

--- Get file content at a specific ref.
---@param filepath string Relative path from git root
---@param ref string? Git ref (nil uses index/HEAD)
---@return string? content nil if file doesn't exist at ref
function M.get_content_at_ref(filepath, ref)
    local root = M.git_root()
    if not root then
        return nil
    end

    local show_ref = (ref or "HEAD") .. ":" .. filepath
    local result = vim.system({ "git", "show", show_ref }, { text = true, cwd = root }):wait()
    if result.code ~= 0 then
        return nil
    end
    return result.stdout
end

return M
