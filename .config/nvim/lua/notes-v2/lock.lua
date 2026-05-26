local M = {}

local jj = require("notes-v2.jj")

local function approved_path(root) return root .. "/.jj/notes-v2-approved" end
local function override_path(root) return root .. "/.jj/notes-v2-unlock" end

local function exists(path)
  return path and vim.fn.filereadable(path) == 1
end

local function read_approved(root)
  local p = approved_path(root)
  if not exists(p) then return {} end
  local out = {}
  for _, line in ipairs(vim.fn.readfile(p)) do
    local trimmed = vim.trim(line)
    if trimmed ~= "" then table.insert(out, trimmed) end
  end
  return out
end

local function contains(list, value)
  for _, v in ipairs(list) do if v == value then return true end end
  return false
end

function M.approved_commits(root)
  return read_approved(root)
end

function M.is_approved(root, commit)
  return contains(read_approved(root), commit)
end

function M.approve_current(root)
  local commit = jj.commit_full("@", root)
  if not commit then return nil end
  if M.is_approved(root, commit) then return commit end
  vim.fn.writefile({ commit }, approved_path(root), "a")
  return commit
end

function M.clear_approvals(root)
  if exists(approved_path(root)) then vim.fn.delete(approved_path(root)) end
end

function M.set_override(root)
  vim.fn.writefile({ "override active" }, override_path(root))
end

function M.clear_override(root)
  if exists(override_path(root)) then vim.fn.delete(override_path(root)) end
end

function M.is_locked(root)
  if exists(override_path(root)) then return false, "override" end
  local current = jj.commit_full("@", root)
  if not current then return false, "no-commit" end
  if M.is_approved(root, current) then return false, "approved" end
  return true, "unapproved"
end

function M.status(root)
  local locked, reason = M.is_locked(root)
  return { locked = locked, reason = reason }
end

return M
