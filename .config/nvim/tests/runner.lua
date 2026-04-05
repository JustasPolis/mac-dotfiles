--- Minimal test runner for nvim --headless
--- Usage: nvim --headless -u NORC -l tests/runner.lua tests/test_*.lua

local passed = 0
local failed = 0
local errors = {}

function describe(name, fn)
    print("  " .. name)
    fn()
end

function it(name, fn)
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        print("    ✓ " .. name)
    else
        failed = failed + 1
        table.insert(errors, { name = name, err = err })
        print("    ✗ " .. name)
        print("      " .. tostring(err))
    end
end

function assert_eq(got, expected, msg)
    if type(got) == "table" and type(expected) == "table" then
        local got_s = vim.inspect(got)
        local exp_s = vim.inspect(expected)
        if got_s ~= exp_s then
            error((msg or "assert_eq") .. "\n  expected: " .. exp_s .. "\n  got:      " .. got_s, 2)
        end
    elseif got ~= expected then
        error((msg or "assert_eq") .. "\n  expected: " .. vim.inspect(expected) .. "\n  got:      " .. vim.inspect(got), 2)
    end
end

function assert_true(val, msg)
    if not val then
        error((msg or "assert_true") .. ": got " .. vim.inspect(val), 2)
    end
end

function assert_nil(val, msg)
    if val ~= nil then
        error((msg or "assert_nil") .. ": got " .. vim.inspect(val), 2)
    end
end

function assert_type(val, expected_type, msg)
    if type(val) ~= expected_type then
        error((msg or "assert_type") .. ": expected " .. expected_type .. ", got " .. type(val), 2)
    end
end

-- Add lua/ to runtime path so require("difftree.*") works
vim.opt.runtimepath:prepend(vim.fn.getcwd())
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

-- Run test files passed as args
local files = {}
for i = 1, #arg do
    if arg[i]:match("%.lua$") then
        table.insert(files, arg[i])
    end
end

for _, file in ipairs(files) do
    print("\n" .. file)
    dofile(file)
end

print(string.format("\n%d passed, %d failed", passed, failed))
if failed > 0 then
    vim.cmd("cquit 1")
else
    vim.cmd("quit")
end
