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

describe("parse_full_diff", function()
    it("parses multiple files with hunks from single diff output", function()
        -- Simulates -U0 output (no context lines)
        local diff = [[
diff --git a/src/main.lua b/src/main.lua
index abc..def 100644
--- a/src/main.lua
+++ b/src/main.lua
@@ -11,1 +11,2 @@
-    old
+    new
+    added
@@ -31,0 +33,1 @@
+inserted
diff --git a/README.md b/README.md
new file mode 100644
--- /dev/null
+++ b/README.md
@@ -0,0 +1,3 @@
+# Title
+
+Hello
]]
        local files, hunks_by_file = git.parse_full_diff(diff)
        assert_eq(#files, 2, "should find 2 files")
        assert_eq(files[1].path, "src/main.lua")
        assert_eq(files[2].path, "README.md")

        local h1 = hunks_by_file["src/main.lua"]
        assert_eq(#h1, 2, "main.lua should have 2 hunks")
        assert_eq(h1[1].change_start, 11)
        assert_eq(h1[1].change_end, 12)
        assert_eq(h1[2].change_start, 33)
        assert_eq(h1[2].change_end, 33)

        local h2 = hunks_by_file["README.md"]
        assert_eq(#h2, 1, "README.md should have 1 hunk")
        assert_eq(h2[1].change_start, 1)
        assert_eq(h2[1].change_end, 3)
    end)

    it("detects file status from diff headers", function()
        local diff = [[
diff --git a/new.lua b/new.lua
new file mode 100644
--- /dev/null
+++ b/new.lua
@@ -0,0 +1 @@
+hello
diff --git a/old.lua b/old.lua
deleted file mode 100644
--- a/old.lua
+++ /dev/null
@@ -1 +0,0 @@
-goodbye
diff --git a/changed.lua b/changed.lua
--- a/changed.lua
+++ b/changed.lua
@@ -1 +1 @@
-old
+new
]]
        local files, _ = git.parse_full_diff(diff)
        assert_eq(#files, 3)
        assert_eq(files[1].status, "A")
        assert_eq(files[1].path, "new.lua")
        assert_eq(files[2].status, "D")
        assert_eq(files[2].path, "old.lua")
        assert_eq(files[3].status, "M")
        assert_eq(files[3].path, "changed.lua")
    end)

    it("returns empty for no diff", function()
        local files, hunks = git.parse_full_diff("")
        assert_eq(#files, 0)
    end)

    it("handles rename", function()
        local diff = [[
diff --git a/old.lua b/new.lua
similarity index 90%
rename from old.lua
rename to new.lua
--- a/old.lua
+++ b/new.lua
@@ -1 +1 @@
-old
+new
]]
        local files, _ = git.parse_full_diff(diff)
        assert_eq(#files, 1)
        assert_eq(files[1].status, "R")
        assert_eq(files[1].path, "new.lua")
    end)

    it("keeps changed files that have no text hunks", function()
        local diff = [[
diff --git a/image.png b/image.png
Binary files a/image.png and b/image.png differ
diff --git a/old.lua b/new.lua
similarity index 100%
rename from old.lua
rename to new.lua
]]
        local files, hunks_by_file = git.parse_full_diff(diff)
        assert_eq(#files, 2)
        assert_eq(files[1], { status = "M", path = "image.png" })
        assert_eq(files[2], { status = "R", path = "new.lua" })
        assert_eq(hunks_by_file["image.png"], {})
        assert_eq(hunks_by_file["new.lua"], {})
    end)
end)

describe("parse_diff_range", function()
    it("parses A..B into left and right refs", function()
        local left, right, mode = git.parse_diff_range("main..feature")
        assert_eq(left, "main")
        assert_eq(right, "feature")
        assert_eq(mode, "..")
    end)

    it("parses A...B (three-dot) into left and right refs", function()
        local left, right, mode = git.parse_diff_range("main...feature")
        assert_eq(left, "main")
        assert_eq(right, "feature")
        assert_eq(mode, "...")
    end)

    it("parses single ref as ref vs working tree", function()
        local left, right, mode = git.parse_diff_range("HEAD~3")
        assert_eq(left, "HEAD~3")
        assert_nil(right)
        assert_nil(mode)
    end)

    it("returns nil,nil for empty/nil input", function()
        local left, right, mode = git.parse_diff_range(nil)
        assert_nil(left)
        assert_nil(right)
        assert_nil(mode)

        left, right, mode = git.parse_diff_range("")
        assert_nil(left)
        assert_nil(right)
        assert_nil(mode)
    end)

    it("handles commit hashes", function()
        local left, right, mode = git.parse_diff_range("abc123..def456")
        assert_eq(left, "abc123")
        assert_eq(right, "def456")
        assert_eq(mode, "..")
    end)
end)

describe("get_all", function()
    it("preserves three-dot semantics in the git diff command", function()
        with_patch(git, "git_root", function() return "/tmp/repo" end, function()
            with_patch(vim, "system", function(cmd, opts)
                assert_eq(cmd, { "git", "diff", "-U0", "main...feature" })
                assert_eq(opts.cwd, "/tmp/repo")
                assert_true(opts.text, "git diff should request text output")
                return {
                    wait = function()
                        return { code = 0, stdout = "" }
                    end,
                }
            end, function()
                local files, hunks_by_file = git.get_all("main", "feature", "...")
                assert_eq(files, {})
                assert_eq(hunks_by_file, {})
            end)
        end)
    end)
end)

describe("get_content_at_ref", function()
    it("reads from the index when ref is nil", function()
        with_patch(git, "git_root", function() return "/tmp/repo" end, function()
            with_patch(vim, "system", function(cmd, opts)
                assert_eq(cmd, { "git", "show", ":lua/difftree/init.lua" })
                assert_eq(opts.cwd, "/tmp/repo")
                return {
                    wait = function()
                        return { code = 0, stdout = "indexed\n" }
                    end,
                }
            end, function()
                local content = git.get_content_at_ref("lua/difftree/init.lua", nil)
                assert_eq(content, "indexed\n")
            end)
        end)
    end)
end)
