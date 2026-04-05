local git = require("difftree.git")

describe("parse_name_status", function()
    it("parses modified, added, deleted files", function()
        local output = "M\tsrc/main.lua\nA\tnew_file.lua\nD\told_file.lua\n"
        local files = git.parse_name_status(output)
        assert_eq(#files, 3)
        assert_eq(files[1], { status = "M", path = "src/main.lua" })
        assert_eq(files[2], { status = "A", path = "new_file.lua" })
        assert_eq(files[3], { status = "D", path = "old_file.lua" })
    end)

    it("returns empty table for empty output", function()
        assert_eq(git.parse_name_status(""), {})
        assert_eq(git.parse_name_status("\n"), {})
    end)

    it("handles renamed files", function()
        local output = "R100\told.lua\tnew.lua\n"
        local files = git.parse_name_status(output)
        assert_eq(#files, 1)
        assert_eq(files[1].status, "R")
    end)
end)

describe("parse_diff_hunks", function()
    it("parses single hunk", function()
        local diff = [[
diff --git a/file.lua b/file.lua
index abc..def 100644
--- a/file.lua
+++ b/file.lua
@@ -10,5 +10,7 @@ function foo()
     context line
-    old line
+    new line
+    added line
     context line
]]
        local hunks = git.parse_diff_hunks(diff)
        assert_eq(#hunks, 1)
        assert_eq(hunks[1].old_start, 10)
        assert_eq(hunks[1].old_count, 5)
        assert_eq(hunks[1].new_start, 10)
        assert_eq(hunks[1].new_count, 7)
        assert_eq(hunks[1].preview, "old line")
    end)

    it("parses multiple hunks", function()
        local diff = [[
diff --git a/file.lua b/file.lua
--- a/file.lua
+++ b/file.lua
@@ -1,3 +1,4 @@
 line1
+inserted
 line2
 line3
@@ -20,4 +21,3 @@
 ctx
-removed
 ctx
]]
        local hunks = git.parse_diff_hunks(diff)
        assert_eq(#hunks, 2)
        assert_eq(hunks[1].old_start, 1)
        assert_eq(hunks[1].new_start, 1)
        assert_eq(hunks[1].new_count, 4)
        assert_eq(hunks[1].preview, "inserted")
        assert_eq(hunks[2].old_start, 20)
        assert_eq(hunks[2].new_start, 21)
        assert_eq(hunks[2].preview, "removed")
    end)

    it("returns empty for no hunks", function()
        assert_eq(git.parse_diff_hunks(""), {})
        assert_eq(git.parse_diff_hunks("Binary files differ\n"), {})
    end)

    it("handles hunk without comma in counts", function()
        local diff = "@@ -1 +1 @@\n-old\n+new\n"
        local hunks = git.parse_diff_hunks(diff)
        assert_eq(#hunks, 1)
        assert_eq(hunks[1].old_count, 1)
        assert_eq(hunks[1].new_count, 1)
    end)

    it("truncates long preview lines", function()
        local long_line = string.rep("a", 100)
        local diff = "@@ -1,2 +1,2 @@\n-" .. long_line .. "\n"
        local hunks = git.parse_diff_hunks(diff)
        assert_eq(#hunks, 1)
        assert_true(#hunks[1].preview <= 63, "preview should be truncated")
    end)
end)

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
end)

describe("parse_diff_range", function()
    it("parses A..B into left and right refs", function()
        local left, right = git.parse_diff_range("main..feature")
        assert_eq(left, "main")
        assert_eq(right, "feature")
    end)

    it("parses A...B (three-dot) into left and right refs", function()
        local left, right = git.parse_diff_range("main...feature")
        assert_eq(left, "main")
        assert_eq(right, "feature")
    end)

    it("parses single ref as ref vs working tree", function()
        local left, right = git.parse_diff_range("HEAD~3")
        assert_eq(left, "HEAD~3")
        assert_nil(right)
    end)

    it("returns nil,nil for empty/nil input", function()
        local left, right = git.parse_diff_range(nil)
        assert_nil(left)
        assert_nil(right)

        left, right = git.parse_diff_range("")
        assert_nil(left)
        assert_nil(right)
    end)

    it("handles commit hashes", function()
        local left, right = git.parse_diff_range("abc123..def456")
        assert_eq(left, "abc123")
        assert_eq(right, "def456")
    end)
end)

describe("build_diff_cmd", function()
    it("builds command for working tree diff (no args)", function()
        local cmd = git.build_diff_cmd(nil, nil)
        assert_eq(cmd, { "git", "diff" })
    end)

    it("builds command for single ref vs working tree", function()
        local cmd = git.build_diff_cmd("HEAD~3", nil)
        assert_eq(cmd, { "git", "diff", "HEAD~3" })
    end)

    it("builds command for ref range", function()
        local cmd = git.build_diff_cmd("main", "feature")
        assert_eq(cmd, { "git", "diff", "main..feature" })
    end)

    it("builds file-specific command", function()
        local cmd = git.build_diff_cmd("HEAD~3", nil, "src/main.lua")
        assert_eq(cmd, { "git", "diff", "HEAD~3", "--", "src/main.lua" })
    end)

    it("builds name-status variant", function()
        local cmd = git.build_diff_cmd("main", "feature", nil, true)
        assert_eq(cmd, { "git", "diff", "--name-status", "main..feature" })
    end)
end)

describe("resolve_base_ref", function()
    it("returns left ref for range diff", function()
        assert_eq(git.resolve_base_ref("main", "feature"), "main")
    end)

    it("returns single ref for ref vs working tree", function()
        assert_eq(git.resolve_base_ref("HEAD~3", nil), "HEAD~3")
    end)

    it("returns nil for plain working tree diff", function()
        assert_nil(git.resolve_base_ref(nil, nil))
    end)
end)

describe("resolve_right_ref", function()
    it("returns right ref for range diff", function()
        assert_eq(git.resolve_right_ref("main", "feature"), "feature")
    end)

    it("returns nil for ref vs working tree", function()
        assert_nil(git.resolve_right_ref("HEAD~3", nil))
    end)

    it("returns nil for plain working tree diff", function()
        assert_nil(git.resolve_right_ref(nil, nil))
    end)
end)
