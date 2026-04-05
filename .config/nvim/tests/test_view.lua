local view = require("difftree.view")
local git = require("difftree.git")

local function with_patch(target, key, value, fn)
    local original = target[key]
    target[key] = value

    local ok, err = pcall(fn)
    target[key] = original

    if not ok then
        error(err, 0)
    end
end

local function with_diff_windows(fn)
    vim.cmd("tabnew")
    local tab = vim.api.nvim_get_current_tabpage()
    local base_win = vim.api.nvim_get_current_win()
    vim.cmd("vsplit")
    local right_win = vim.api.nvim_get_current_win()

    local ok, err = pcall(fn, base_win, right_win)

    view.close()
    if vim.api.nvim_tabpage_is_valid(tab) then
        vim.cmd("tabclose!")
    end

    if not ok then
        error(err, 0)
    end
end

describe("view.create_base_buf", function()
    it("creates scratch buffer with content", function()
        local content = "line1\nline2\nline3\n"
        local buf = view.create_base_buf(content, "test.lua", "HEAD")
        assert_true(vim.api.nvim_buf_is_valid(buf), "buffer should be valid")
        assert_eq(vim.bo[buf].buftype, "nofile")
        assert_eq(vim.bo[buf].modifiable, false)

        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        assert_eq(lines[1], "line1")
        assert_eq(lines[2], "line2")
        assert_eq(lines[3], "line3")

        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("creates empty buffer when content is nil", function()
        local buf = view.create_base_buf(nil, "new_file.lua", "main")
        assert_true(vim.api.nvim_buf_is_valid(buf), "buffer should be valid")
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        assert_eq(lines, { "" })

        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("includes ref and filepath in buffer name", function()
        local buf = view.create_base_buf("x\n", "foo.lua", "abc123")
        local name = vim.api.nvim_buf_get_name(buf)
        assert_true(name:find("abc123") ~= nil, "buffer name should contain ref")
        assert_true(name:find("foo.lua") ~= nil, "buffer name should contain filepath")

        vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("creates unique buffer names for same file", function()
        local buf1 = view.create_base_buf("a\n", "same.lua", "HEAD")
        local buf2 = view.create_base_buf("b\n", "same.lua", "HEAD")
        local name1 = vim.api.nvim_buf_get_name(buf1)
        local name2 = vim.api.nvim_buf_get_name(buf2)
        assert_true(name1 ~= name2, "buffer names should be unique")

        vim.api.nvim_buf_delete(buf1, { force = true })
        vim.api.nvim_buf_delete(buf2, { force = true })
    end)
end)

describe("view state tracking", function()
    it("starts with no active diff", function()
        assert_true(not view.is_open(), "should not be open initially")
    end)
end)

describe("view.open", function()
    it("loads both compared refs for ref-vs-ref diffs", function()
        with_diff_windows(function(base_win, right_win)
            view.set_windows(base_win, right_win)

            with_patch(git, "git_root", function() return "/tmp/repo" end, function()
                with_patch(git, "get_content_at_ref", function(filepath, ref)
                    assert_eq(filepath, "lua/difftree/init.lua")
                    if ref == "feature" then
                        return "from-feature\n"
                    end
                    if ref == "main" then
                        return "from-main\n"
                    end
                    error("unexpected ref: " .. tostring(ref))
                end, function()
                    view.open("lua/difftree/init.lua", 1, "main", "feature", "..")

                    local base_buf = vim.api.nvim_win_get_buf(base_win)
                    local right_buf = vim.api.nvim_win_get_buf(right_win)

                    assert_eq(vim.bo[base_buf].buftype, "nofile")
                    assert_eq(vim.bo[right_buf].buftype, "nofile")
                    assert_true(vim.api.nvim_buf_get_name(base_buf):find("feature") ~= nil)
                    assert_true(vim.api.nvim_buf_get_name(right_buf):find("main") ~= nil)
                    assert_eq(vim.api.nvim_buf_get_lines(base_buf, 0, -1, false), { "from-feature" })
                    assert_eq(vim.api.nvim_buf_get_lines(right_buf, 0, -1, false), { "from-main" })
                end)
            end)
        end)
    end)

    it("uses the merge-base on the left side for three-dot diffs", function()
        with_diff_windows(function(base_win, right_win)
            view.set_windows(base_win, right_win)

            with_patch(git, "git_root", function() return "/tmp/repo" end, function()
                with_patch(git, "get_merge_base", function(left, right)
                    assert_eq(left, "main")
                    assert_eq(right, "feature")
                    return "abc123"
                end, function()
                    local seen_refs = {}
                    with_patch(git, "get_content_at_ref", function(_, ref)
                        table.insert(seen_refs, ref)
                        return ref .. "\n"
                    end, function()
                        view.open("lua/difftree/init.lua", 1, "main", "feature", "...")

                        local right_buf = vim.api.nvim_win_get_buf(right_win)

                        assert_eq(seen_refs, { "feature", "abc123" })
                        assert_true(vim.api.nvim_buf_get_name(right_buf):find("abc123") ~= nil)
                    end)
                end)
            end)
        end)
    end)
end)
