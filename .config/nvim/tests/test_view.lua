local view = require("difftree.view")

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
