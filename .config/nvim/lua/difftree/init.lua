---@class difftree
local M = {}

local git = require("difftree.git")
local view = require("difftree.view")

---@type any? NuiSplit instance
M._split = nil
---@type any? NuiTree instance
M._tree = nil
---@type integer? autocmd group id
M._augroup = nil
---@type string? left ref for current diff
M._left = nil
---@type string? right ref for current diff
M._right = nil
---@type integer? left diff window
M._base_win = nil
---@type integer? right diff window
M._right_win = nil

--- Build NuiTree nodes from file and hunk data.
---@param files difftree.FileEntry[]
---@param hunks_by_file table<string, difftree.Hunk[]>
---@return any[] NuiTree.Node[]
function M.build_tree_nodes(files, hunks_by_file)
    local NuiTree = require("nui.tree")

    if #files == 0 then
        return { NuiTree.Node({ id = "__info__", type = "info", text = "No changes" }) }
    end

    local nodes = {}
    for _, file in ipairs(files) do
        local hunks = hunks_by_file[file.path] or {}
        local hunk_nodes = {}
        for i, hunk in ipairs(hunks) do
            local cs = hunk.change_start or hunk.new_start
            local ce = hunk.change_end or cs
            local range
            if cs == ce then
                range = string.format("%d", cs)
            else
                range = string.format("%d-%d", cs, ce)
            end
            table.insert(
                hunk_nodes,
                NuiTree.Node({
                    id = file.path .. ":hunk:" .. i,
                    type = "hunk",
                    filepath = file.path,
                    line = cs,
                    range = range,
                    preview = hunk.preview,
                })
            )
        end

        local file_node
        if #hunk_nodes > 0 and file.status ~= "D" then
            file_node = NuiTree.Node({
                id = file.path,
                type = "file",
                filepath = file.path,
                status = file.status,
            }, hunk_nodes)
        else
            file_node = NuiTree.Node({
                id = file.path,
                type = "file",
                filepath = file.path,
                status = file.status,
            })
        end
        table.insert(nodes, file_node)
    end
    return nodes
end

--- Render a single tree node as a NuiLine.
---@param node any NuiTree.Node
---@return any NuiLine
function M.prepare_node(node)
    local NuiLine = require("nui.line")
    local line = NuiLine()

    if node.type == "info" then
        line:append("  " .. node.text, "DiffTreePreview")
    elseif node.type == "file" then
        local status_hl = ({
            M = "DiffTreeModified",
            A = "DiffTreeAdded",
            D = "DiffTreeDeleted",
            R = "DiffTreeModified",
        })[node.status] or "DiffTreeFile"
        line:append(node.status .. " ", status_hl)

        -- File icon from nvim-web-devicons
        local ok, devicons = pcall(require, "nvim-web-devicons")
        if ok then
            local filename = vim.fn.fnamemodify(node.filepath, ":t")
            local ext = vim.fn.fnamemodify(node.filepath, ":e")
            local icon, icon_hl = devicons.get_icon(filename, ext, { default = true })
            if icon then
                line:append(icon .. " ", icon_hl)
            end
        end

        line:append(node.filepath, "DiffTreeFile")
    elseif node.type == "hunk" then
        line:append("  ", nil)
        line:append(node.range, "DiffTreeRange")
    end

    return line
end

--- Set up highlight groups using the theme palette.
local function setup_highlights()
    local ok, theme = pcall(require, "theme")
    local p = ok and theme.palette
        or {
            fg = "#c9c7cd",
            dimmed = "#7b7b80",
            separator = "#353539",
            accent = "#c9a5b5",
            secondary = "#bdb2e0",
            muted = "#d4b5a0",
        }

    vim.api.nvim_set_hl(0, "DiffTreeFile", { fg = p.fg })
    vim.api.nvim_set_hl(0, "DiffTreeModified", { fg = p.muted })
    vim.api.nvim_set_hl(0, "DiffTreeAdded", { fg = p.secondary })
    vim.api.nvim_set_hl(0, "DiffTreeDeleted", { fg = p.accent })
    vim.api.nvim_set_hl(0, "DiffTreeRange", { fg = p.muted })
    vim.api.nvim_set_hl(0, "DiffTreePreview", { fg = p.dimmed })
    vim.api.nvim_set_hl(0, "DiffTreeIcon", { fg = p.dimmed })
    vim.api.nvim_set_hl(0, "DiffTreeCursorLine", { bg = p.separator })
end

--- Fetch git data and build fresh tree nodes (single git call).
---@return any[] NuiTree.Node[]
local function fetch_nodes()
    local files, hunks_by_file = git.get_all(M._left, M._right)
    return M.build_tree_nodes(files, hunks_by_file)
end

--- Refresh the tree with fresh git data, all nodes expanded.
function M.refresh()
    if not M._tree or not M._split then
        return
    end

    local nodes = fetch_nodes()
    M._tree:set_nodes(nodes)

    for _, node in ipairs(M._tree:get_nodes()) do
        if node.type == "file" and node:has_children() then
            node:expand()
        end
    end

    M._tree:render()
end

--- Set up keymaps on the tree split buffer.
---@param split any NuiSplit
---@param tree any NuiTree
local function setup_keymaps(split, tree)
    local map_opts = { noremap = true, silent = true }

    split:map("n", "<CR>", function()
        local node = tree:get_node()
        if not node then
            return
        end

        if node.type == "file" then
            -- Open diff at first hunk's line (or line 1)
            local target = 1
            local children = node:get_child_ids()
            if children and #children > 0 then
                local first_hunk = tree:get_node(children[1])
                if first_hunk then
                    target = first_hunk.line
                end
            end
            view.open(node.filepath, target, M._left, M._right)
        elseif node.type == "hunk" then
            view.open(node.filepath, node.line, M._left, M._right)
        end
    end, map_opts)

    split:map("n", "q", function()
        M.close()
    end, map_opts)

    split:map("n", "r", function()
        M.refresh()
    end, map_opts)
end

--- Open the DiffTree panel.
---@param range string? Git diff range (e.g. "HEAD~3", "main..feature")
function M.open(range)
    local left, right = git.parse_diff_range(range)
    M._left = left
    M._right = right

    if M._split then
        M.refresh()
        return
    end

    vim.cmd("packadd nui.nvim")
    setup_highlights()

    -- Use the current window as the left diff pane
    local base_win = vim.api.nvim_get_current_win()

    -- Split it vertically to create the right diff pane (50/50)
    vim.cmd("rightbelow vsplit")
    local right_win = vim.api.nvim_get_current_win()

    -- Equalize the two diff panes
    vim.cmd("wincmd =")

    M._base_win = base_win
    M._right_win = right_win

    -- Tell the view module about these windows
    view.set_windows(base_win, right_win)

    -- Now create the tree panel at the bottom (spans full width)
    local Split = require("nui.split")
    local NuiTree = require("nui.tree")

    local split = Split({
        relative = "editor",
        position = "bottom",
        size = "30%",
        enter = true,
        buf_options = {
            buftype = "nofile",
            modifiable = false,
            filetype = "difftree",
        },
        win_options = {
            number = false,
            relativenumber = false,
            signcolumn = "no",
            winfixheight = true,
            cursorline = true,
            winhighlight = "CursorLine:DiffTreeCursorLine",
        },
    })
    split:mount()

    local nodes = fetch_nodes()
    local tree = NuiTree({
        bufnr = split.bufnr,
        nodes = nodes,
        get_node_id = function(node)
            return node.id
        end,
        prepare_node = M.prepare_node,
    })

    -- Expand all file nodes by default
    for _, node in ipairs(tree:get_nodes()) do
        if node.type == "file" and node:has_children() then
            node:expand()
        end
    end

    tree:render()

    setup_keymaps(split, tree)

    M._split = split
    M._tree = tree

    -- Auto-refresh on save (only useful when diffing against working tree)
    if not M._right then
        M._augroup = vim.api.nvim_create_augroup("difftree_refresh", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = M._augroup,
            callback = function()
                if M._tree and M._split then
                    M.refresh()
                end
            end,
        })
    end
end

--- Close the DiffTree panel and any open diff view.
function M.close()
    -- Collect window refs before clearing any state
    local right_win = M._right_win
    local split = M._split

    -- Clean up diff state (diffoff)
    view.close()

    -- Close right diff window
    if right_win and vim.api.nvim_win_is_valid(right_win) then
        vim.api.nvim_win_close(right_win, true)
    end

    -- Unmount tree panel
    if split then
        split:unmount()
    end

    if M._augroup then
        vim.api.nvim_del_augroup_by_id(M._augroup)
        M._augroup = nil
    end

    M._split = nil
    M._tree = nil
    M._left = nil
    M._right = nil
    M._base_win = nil
    M._right_win = nil
end

--- Toggle the DiffTree panel.
---@param range string?
function M.toggle(range)
    if M._split then
        M.close()
    else
        M.open(range)
    end
end

-- Register command with optional args
vim.api.nvim_create_user_command("DiffTree", function(opts)
    local range = opts.args ~= "" and opts.args or nil
    M.toggle(range)
end, {
    nargs = "?",
    desc = "Toggle DiffTree panel",
    complete = function()
        local completions = { "HEAD~1", "HEAD~3", "main..", "origin/main.." }
        local root = git.git_root()
        if root then
            local result = vim.system(
                { "git", "branch", "--format=%(refname:short)" },
                { text = true, cwd = root }
            ):wait()
            if result.code == 0 and result.stdout then
                for branch in result.stdout:gmatch("[^\n]+") do
                    table.insert(completions, branch .. "..")
                end
            end
        end
        return completions
    end,
})

return M
