-- Need nui.nvim for tree node building
vim.cmd("set packpath+=" .. vim.fn.expand("~/.local/share/nvim/site"))
vim.cmd("packadd nui.nvim")

local difftree = require("difftree")
local git = require("difftree.git")

describe("build_tree_nodes", function()
    it("builds file nodes with hunk children", function()
        local NuiTree = require("nui.tree")

        ---@type difftree.FileEntry[]
        local files = {
            { status = "M", path = "src/main.lua" },
        }
        ---@type table<string, difftree.Hunk[]>
        local hunks_by_file = {
            ["src/main.lua"] = {
                { old_start = 10, old_count = 5, new_start = 10, new_count = 7, preview = "changed line" },
                { old_start = 30, old_count = 3, new_start = 32, new_count = 4, preview = "another change" },
            },
        }

        local nodes = difftree.build_tree_nodes(files, hunks_by_file)
        assert_eq(#nodes, 1, "should have 1 file node")

        local file_node = nodes[1]
        assert_eq(file_node.type, "file")
        assert_eq(file_node.filepath, "src/main.lua")
        assert_eq(file_node.status, "M")
        assert_true(file_node:has_children(), "file node should have children")

        -- Initialize through a NuiTree to populate _child_ids
        local buf = vim.api.nvim_create_buf(false, true)
        local tree = NuiTree({
            bufnr = buf,
            nodes = nodes,
            get_node_id = function(node) return node.id end,
        })
        local initialized_node = tree:get_node("src/main.lua")
        local children = initialized_node:get_child_ids()
        assert_eq(#children, 2, "should have 2 hunk children")
        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("builds file node with no hunks for binary files", function()
        local files = { { status = "M", path = "image.png" } }
        local hunks_by_file = { ["image.png"] = {} }

        local nodes = difftree.build_tree_nodes(files, hunks_by_file)
        assert_eq(#nodes, 1)
        assert_true(not nodes[1]:has_children(), "binary file should have no children")
    end)

    it("returns info node when no changes", function()
        local nodes = difftree.build_tree_nodes({}, {})
        assert_eq(#nodes, 1)
        assert_eq(nodes[1].type, "info")
    end)

    it("builds multiple file nodes", function()
        local files = {
            { status = "M", path = "a.lua" },
            { status = "A", path = "b.lua" },
            { status = "D", path = "c.lua" },
        }
        local hunks_by_file = {
            ["a.lua"] = { { old_start = 1, old_count = 1, new_start = 1, new_count = 1, preview = "x" } },
            ["b.lua"] = { { old_start = 1, old_count = 0, new_start = 1, new_count = 5, preview = "new" } },
            ["c.lua"] = { { old_start = 1, old_count = 3, new_start = 1, new_count = 0, preview = "del" } },
        }

        local nodes = difftree.build_tree_nodes(files, hunks_by_file)
        assert_eq(#nodes, 3)
        assert_eq(nodes[1].status, "M")
        assert_eq(nodes[2].status, "A")
        assert_eq(nodes[3].status, "D")
    end)
end)

describe("prepare_node", function()
    it("renders file node with status and path", function()
        local NuiTree = require("nui.tree")
        local node = NuiTree.Node({
            id = "test.lua",
            type = "file",
            filepath = "test.lua",
            status = "M",
        })
        local line = difftree.prepare_node(node)
        local text = line:content()
        assert_true(text:find("M") ~= nil, "should contain status M")
        assert_true(text:find("test.lua") ~= nil, "should contain filepath")
    end)

    it("renders hunk node with range only", function()
        local NuiTree = require("nui.tree")
        local node = NuiTree.Node({
            id = "test.lua:hunk:1",
            type = "hunk",
            filepath = "test.lua",
            line = 10,
            range = "L10-16",
            preview = "some change",
        })
        local line = difftree.prepare_node(node)
        local text = line:content()
        assert_true(text:find("10%-16") ~= nil, "should contain range")
        -- Preview text should NOT be in output
        assert_true(text:find("some change") == nil, "should not contain preview")
    end)
end)
