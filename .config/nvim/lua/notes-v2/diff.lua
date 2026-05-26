local M = {}

local jj = require("notes-v2.jj")

local function split_content(content)
  local lines = vim.split(content or "", "\n", { plain = true })
  if #lines > 0 and lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

local function write_temp_version(filename, content)
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local temp_path = vim.fs.joinpath(dir, filename)
  local fd = vim.uv.fs_open(temp_path, "w", 384)
  if not fd then
    vim.fn.delete(dir, "rf")
    return nil, nil
  end
  vim.uv.fs_write(fd, content, -1)
  vim.uv.fs_close(fd)
  return dir, temp_path
end

local function transform_file(data, old_content, new_content)
  local old_lines = split_content(old_content)
  local new_lines = split_content(new_content)

  local left_hl, right_hl = {}, {}
  for _, chunk in ipairs(data.chunks or {}) do
    for _, entry in ipairs(chunk) do
      if entry.lhs then
        local n = entry.lhs.line_number
        left_hl[n] = left_hl[n] or {}
        for _, c in ipairs(entry.lhs.changes) do
          left_hl[n][#left_hl[n] + 1] = { start = c.start, ["end"] = c["end"] }
        end
      end
      if entry.rhs then
        local n = entry.rhs.line_number
        right_hl[n] = right_hl[n] or {}
        for _, c in ipairs(entry.rhs.changes) do
          right_hl[n][#right_hl[n] + 1] = { start = c.start, ["end"] = c["end"] }
        end
      end
    end
  end

  local rows = {}
  local old_to_row, new_to_row = {}, {}

  for i, pair in ipairs(data.aligned_lines or {}) do
    local old_idx = pair[1]
    local new_idx = pair[2]
    local old_nil = old_idx == vim.NIL
    local new_nil = new_idx == vim.NIL

    rows[#rows + 1] = {
      left = {
        content = old_nil and "" or (old_lines[old_idx + 1] or ""),
        is_filler = old_nil,
        highlights = old_nil and {} or (left_hl[old_idx] or {}),
      },
      right = {
        content = new_nil and "" or (new_lines[new_idx + 1] or ""),
        is_filler = new_nil,
        highlights = new_nil and {} or (right_hl[new_idx] or {}),
      },
    }

    if not old_nil then old_to_row[old_idx] = i end
    if not new_nil then new_to_row[new_idx] = i end
  end

  local hunk_starts = {}
  for _, chunk in ipairs(data.chunks or {}) do
    if #chunk > 0 then
      local first = chunk[1]
      local row_idx = (first.lhs and old_to_row[first.lhs.line_number])
        or (first.rhs and new_to_row[first.rhs.line_number])
      if row_idx then
        hunk_starts[#hunk_starts + 1] = row_idx - 1
      end
    end
  end

  return {
    path = data.path,
    language = data.language,
    rows = rows,
    hunk_starts = hunk_starts,
  }
end

M.transform_file = transform_file

local function synthesize_aligned(old_lines, new_lines)
  local pairs_ = {}
  local n_old, n_new = #old_lines, #new_lines
  if n_old == 0 and n_new > 0 then
    for i = 0, n_new - 1 do pairs_[#pairs_ + 1] = { vim.NIL, i } end
  elseif n_new == 0 and n_old > 0 then
    for i = 0, n_old - 1 do pairs_[#pairs_ + 1] = { i, vim.NIL } end
  end
  return pairs_
end

local function run_difft(old_path, new_path, old_content, new_content)
  local r = vim.system({
    "env", "DFT_UNSTABLE=yes",
    "difft",
    "--display", "json",
    "--context", "9999",
    old_path,
    new_path,
  }, { text = true }):wait(5000)

  if r.code ~= 0 or not r.stdout or r.stdout == "" then return nil end

  local first_data
  for _, line in ipairs(vim.split(vim.trim(r.stdout), "\n", { trimempty = true })) do
    local ok, data = pcall(vim.json.decode, line)
    if ok and data then
      first_data = first_data or data
      if data.aligned_lines and #data.aligned_lines > 0 then return data end
    end
  end

  if first_data and (first_data.status == "created" or first_data.status == "deleted") then
    first_data.aligned_lines = synthesize_aligned(
      split_content(old_content),
      split_content(new_content)
    )
    first_data.chunks = first_data.chunks or {}
    return first_data
  end
  return first_data
end

local function read_worktree_file(root, path)
  local abs = root .. "/" .. path
  local ok, lines = pcall(vim.fn.readfile, abs, "b")
  if not ok then return "" end
  return table.concat(lines, "\n")
end

function M.compute_file_diff(from_commit, to_commit, path, root)
  if not root then return nil, "no workspace" end

  local old_content = jj.file_show(from_commit, path, root) or ""
  local new_content
  local current_at = jj.commit_full("@", root)
  if to_commit and current_at and to_commit == current_at then
    new_content = read_worktree_file(root, path)
  else
    new_content = jj.file_show(to_commit, path, root) or ""
  end

  local filename = vim.fs.basename(path)
  local old_dir, old_path = write_temp_version(filename, old_content)
  local new_dir, new_path = write_temp_version(filename, new_content)
  if not old_path or not new_path then
    if old_dir then vim.fn.delete(old_dir, "rf") end
    if new_dir then vim.fn.delete(new_dir, "rf") end
    return nil, "tempfile failed"
  end

  local data = run_difft(old_path, new_path, old_content, new_content)

  vim.fn.delete(old_dir, "rf")
  vim.fn.delete(new_dir, "rf")

  if not data then return nil, "difft failed" end
  data.path = path

  -- If difft returned no alignment (e.g., files match closely or it bailed
  -- out on tiny diffs), synthesize a 1:1 line alignment so both panes still
  -- render content, just with no highlights.
  if not data.aligned_lines or #data.aligned_lines == 0 then
    local old_lines = split_content(old_content)
    local new_lines = split_content(new_content)
    data.aligned_lines = {}
    local n = math.max(#old_lines, #new_lines)
    for i = 0, n - 1 do
      local lhs = (i < #old_lines) and i or vim.NIL
      local rhs = (i < #new_lines) and i or vim.NIL
      table.insert(data.aligned_lines, { lhs, rhs })
    end
    data.chunks = data.chunks or {}
  end

  local result = transform_file(data, old_content, new_content)
  result.from_commit = from_commit
  result.to_commit = to_commit
  return result
end

function M.count_changes(rows)
  local add, del = 0, 0
  for _, row in ipairs(rows or {}) do
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

return M
