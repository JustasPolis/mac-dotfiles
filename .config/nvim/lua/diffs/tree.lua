--- File tree panel using nui.nvim NuiSplit + NuiTree.
--- Flat file list showing +/- line counts.
local M = {}

---@type any? NuiSplit instance
M._split = nil
---@type any? NuiTree instance
M._tree = nil

--- Cached modules
---@type any?
local _NuiLine = nil
---@type any?
local _devicons = nil

--- Count added/deleted lines from diff rows.
---@param rows table[]
---@return number additions, number deletions
local function count_changes(rows)
    local add, del = 0, 0
    for _, row in ipairs(rows) do
        local lf, rf = row.left.is_filler, row.right.is_filler
        if lf and not rf then
            add = add + 1
        elseif rf and not lf then
            del = del + 1
        elseif not lf and not rf then
            local has_hl = #row.left.highlights > 0 or #row.right.highlights > 0
            if has_hl then
                add = add + 1
                del = del + 1
            end
        end
    end
    return add, del
end

--- Build NuiTree nodes from difftastic file data.
---@param files table[] Files from Rust library
---@return any[] NuiTree.Node[]
function M.build_nodes(files)
    local NuiTree = require("nui.tree")

    if #files == 0 then
        return { NuiTree.Node({ id = "__info__", type = "info", text = "No changes" }) }
    end

    local nodes = {}
    for idx, file in ipairs(files) do
        local add, del = count_changes(file.rows or {})
        table.insert(nodes, NuiTree.Node({
            id = file.path,
            type = "file",
            filepath = file.path,
            file_idx = idx,
            additions = add,
            deletions = del,
        }))
    end

    return nodes
end

--- Render a single tree node as a NuiLine.
---@param node any NuiTree.Node
---@return any NuiLine
function M.prepare_node(node)
    if not _NuiLine then
        _NuiLine = require("nui.line")
    end
    if _devicons == nil then
        local ok, mod = pcall(require, "nvim-web-devicons")
        _devicons = ok and mod or false
    end

    local line = _NuiLine()

    if node.type == "info" then
        line:append("  " .. node.text, "DifftTreeRange")
    elseif node.type == "file" then
        line:append("  ")

        if _devicons then
            local filename = vim.fn.fnamemodify(node.filepath, ":t")
            local ext = vim.fn.fnamemodify(node.filepath, ":e")
            local icon, icon_hl = _devicons.get_icon(filename, ext, { default = true })
            if icon then
                line:append(icon .. " ", icon_hl)
            end
        end

        line:append(node.filepath, "DifftTreeFile")

        if node.additions > 0 or node.deletions > 0 then
            line:append(" ")
            line:append("+" .. node.additions, "DifftFileAdded")
            line:append(" ")
            line:append("-" .. node.deletions, "DifftFileDeleted")
        end
    end

    return line
end

--- Open the tree panel.
---@param state table Plugin state (files, tree_win, tree_buf set here)
function M.open(state)
    vim.cmd("packadd nui.nvim")

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
            filetype = "diffs-tree",
        },
        win_options = {
            number = false,
            relativenumber = false,
            signcolumn = "no",
            winfixheight = true,
            cursorline = false,
        },
    })
    split:mount()

    state.tree_win = split.winid
    state.tree_buf = split.bufnr

    local nodes = M.build_nodes(state.files)
    local tree = NuiTree({
        bufnr = split.bufnr,
        nodes = nodes,
        get_node_id = function(node)
            return node.id
        end,
        prepare_node = M.prepare_node,
    })

    tree:render()

    local diffs = require("diffs")
    local keys = diffs.config.keymaps
    local map_opts = { noremap = true, silent = true }

    split:map("n", keys.select, function()
        local node = tree:get_node()
        if node and node.type == "file" then
            diffs.show_file(node.file_idx)
        end
    end, map_opts)

    split:map("n", keys.close, function()
        diffs.close()
    end, map_opts)

    split:map("n", keys.next_file, function()
        diffs.next_file()
    end, map_opts)

    split:map("n", keys.prev_file, function()
        diffs.prev_file()
    end, map_opts)

    M._split = split
    M._tree = tree
end

--- Close the tree panel.
function M.close()
    if M._split then
        M._split:unmount()
    end
    M._split = nil
    M._tree = nil
end

--- Highlight the currently active file in the tree.
---@param state table Plugin state
function M.highlight_current(state)
    if not M._tree or not state.tree_buf then
        return
    end

    local ns = vim.api.nvim_create_namespace("diffs-tree-current")
    vim.api.nvim_buf_clear_namespace(state.tree_buf, ns, 0, -1)

    local line_count = vim.api.nvim_buf_line_count(state.tree_buf)
    for linenr = 1, line_count do
        local node = M._tree:get_node(linenr)
        if node and node.file_idx == state.current_file_idx then
            vim.api.nvim_buf_set_extmark(state.tree_buf, ns, linenr - 1, 0, {
                line_hl_group = "DifftTreeCursorLine",
            })
            if state.tree_win and vim.api.nvim_win_is_valid(state.tree_win) then
                vim.api.nvim_win_set_cursor(state.tree_win, { linenr, 0 })
            end
            break
        end
    end
end

--- Collect file indices in tree order.
---@return number[]
local function collect_files()
    if not M._tree then return {} end
    local files = {}
    for _, node in ipairs(M._tree:get_nodes()) do
        if node.file_idx then
            files[#files + 1] = node.file_idx
        end
    end
    return files
end

function M.next_file_in_display_order(current_idx)
    local files = collect_files()
    for i, idx in ipairs(files) do
        if idx == current_idx and files[i + 1] then
            return files[i + 1]
        end
    end
    return nil
end

function M.prev_file_in_display_order(current_idx)
    local files = collect_files()
    for i, idx in ipairs(files) do
        if idx == current_idx and i > 1 then
            return files[i - 1]
        end
    end
    return nil
end

function M.first_file_in_display_order()
    local files = collect_files()
    return files[1]
end

function M.last_file_in_display_order()
    local files = collect_files()
    return files[#files]
end

return M
