local M = {}

local function run(args, opts)
  opts = opts or {}
  local result = vim.system(
    args,
    { cwd = opts.cwd, text = true, stdin = opts.stdin }
  ):wait()
  return result
end

local function trim(s)
  local out = (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
  return out
end

function M.workspace_root(cwd)
  local r = run({ "jj", "workspace", "root" }, { cwd = cwd })
  if r.code ~= 0 then return nil end
  return trim(r.stdout)
end

function M.snapshot(cwd)
  run({ "jj", "debug", "snapshot" }, { cwd = cwd })
end

local function log_template(rev, template, cwd)
  local r = run(
    { "jj", "log", "-r", rev, "--no-graph", "-T", template },
    { cwd = cwd }
  )
  if r.code ~= 0 then return nil end
  return trim(r.stdout)
end

function M.current_commit_id(cwd)
  return log_template("@", "commit_id.short()", cwd)
end

function M.current_change_id(cwd)
  return log_template("@", "change_id.short()", cwd)
end

function M.commit_full(commit_short, cwd)
  return log_template(commit_short, "commit_id", cwd)
end

function M.evolog_commits(cwd)
  local r = run(
    { "jj", "evolog", "-r", "@", "--no-graph", "-T", "commit.commit_id() ++ \"\\n\"" },
    { cwd = cwd }
  )
  if r.code ~= 0 then return {} end
  local out = {}
  for line in (r.stdout or ""):gmatch("[^\n]+") do
    if line ~= "" then table.insert(out, line) end
  end
  return out
end

function M.file_show(commit_id, path, cwd)
  local r = run(
    { "jj", "file", "show", "-r", commit_id, path },
    { cwd = cwd }
  )
  if r.code ~= 0 then return nil end
  return r.stdout or ""
end

function M.file_diff(from_commit, to_commit, path, cwd)
  local args = { "jj", "diff", "--git" }
  if from_commit then table.insert(args, "--from"); table.insert(args, from_commit) end
  if to_commit then table.insert(args, "--to"); table.insert(args, to_commit) end
  table.insert(args, "--")
  table.insert(args, path)
  local r = run(args, { cwd = cwd })
  if r.code ~= 0 then return "" end
  return r.stdout or ""
end

function M.diff_files(from_commit, to_commit, cwd)
  local args = { "jj", "diff", "--name-only" }
  if from_commit then table.insert(args, "--from"); table.insert(args, from_commit) end
  if to_commit then table.insert(args, "--to"); table.insert(args, to_commit) end
  local r = run(args, { cwd = cwd })
  if r.code ~= 0 then return {} end
  local out = {}
  for line in (r.stdout or ""):gmatch("[^\n]+") do
    if line ~= "" then table.insert(out, line) end
  end
  return out
end

function M.diff_summary(from_commit, to_commit, cwd)
  local args = { "jj", "diff", "--summary" }
  if from_commit then table.insert(args, "--from"); table.insert(args, from_commit) end
  if to_commit then table.insert(args, "--to"); table.insert(args, to_commit) end
  local r = run(args, { cwd = cwd })
  if r.code ~= 0 then return {} end
  local out = {}
  for line in (r.stdout or ""):gmatch("[^\n]+") do
    local kind, path = line:match("^(%S)%s+(.+)$")
    if kind and path then table.insert(out, { kind = kind, path = path }) end
  end
  return out
end

return M
