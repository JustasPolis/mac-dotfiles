local M = {}

local jj = require("notes-v2.jj")
local diff = require("notes-v2.diff")
local lock = require("notes-v2.lock")

local ANCHOR_VAR = "notes_v2_anchor_commit"
local PATH_VAR = "notes_v2_anchor_path"
local ROOT_VAR = "notes_v2_anchor_root"

local LEFT_NS = vim.api.nvim_create_namespace("notes-v2-review-left")
local RIGHT_NS = vim.api.nvim_create_namespace("notes-v2-review-right")
local TREE_NS = vim.api.nvim_create_namespace("notes-v2-review-tree")

vim.api.nvim_set_hl(0, "DifftRemoved", { default = true, link = "DiffDelete" })
vim.api.nvim_set_hl(0, "DifftAdded", { default = true, link = "DiffAdd" })
vim.api.nvim_set_hl(0, "DifftFiller", { default = true, link = "Conceal" })

local FILETYPES = {
  Rust = "rust", Lua = "lua", TOML = "toml", JSON = "json",
  JavaScript = "javascript", TypeScript = "typescript",
  Python = "python", Go = "go", C = "c", ["C++"] = "cpp",
  Java = "java", Ruby = "ruby", Shell = "sh", Bash = "bash",
  Markdown = "markdown", YAML = "yaml", HTML = "html", CSS = "css",
  Swift = "swift",
}

local KIND_HL = {
  A = "DiffAdd", M = "DiffChange", D = "DiffDelete",
  R = "DiffChange", C = "DiffChange",
}

M.state = {
  tabpage = nil, origin_tabpage = nil,
  left_win = nil, left_buf = nil,
  right_win = nil, right_buf = nil,
  scratch_right_buf = nil,
  tree_split = nil, tree_win = nil, tree_buf = nil,
  from_commit = nil, to_commit = nil, root = nil,
  files = {}, tree_node_map = {}, current_file = nil,
  hunk_positions_left = {}, hunk_positions_right = {},
  scroll_augroup = nil, syncing = false, sync_map = nil,
  decorated_real_bufs = {},
}

local function safe_set_cursor(win, pos)
  if not win or not vim.api.nvim_win_is_valid(win) then return end
  local buf = vim.api.nvim_win_get_buf(win)
  local max = math.max(1, vim.api.nvim_buf_line_count(buf))
  pos[1] = math.max(1, math.min(pos[1], max))
  pcall(vim.api.nvim_win_set_cursor, win, pos)
end

local function setup_diff_pane(win)
  vim.wo[win].scrollbind = false
  vim.wo[win].cursorbind = false
  vim.wo[win].number = true
  vim.wo[win].signcolumn = "yes:2"
  vim.wo[win].wrap = false
  vim.wo[win].diff = false
end

local function ensure_treesitter(buf, ft)
  if not vim.api.nvim_buf_is_valid(buf) or not ft or ft == "" then return end
  if not pcall(vim.treesitter.language.add, ft) then return end
  if vim.bo[buf].filetype ~= ft then vim.bo[buf].filetype = ft end
  pcall(vim.treesitter.start, buf, ft)
end

local function visual_to_line(visual, cum_fillers, count)
  local best = 1
  for i = 1, count do
    local v = i + (cum_fillers[i] or 0)
    if v <= visual then best = i else break end
  end
  return best
end

local function setup_scroll_sync()
  if M.state.scroll_augroup then
    pcall(vim.api.nvim_del_augroup_by_id, M.state.scroll_augroup)
  end
  M.state.scroll_augroup = vim.api.nvim_create_augroup("notes-v2-review-scroll",
    { clear = true })
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = M.state.scroll_augroup,
    callback = function()
      if M.state.syncing or not M.state.sync_map then return end
      M.state.syncing = true
      local map = M.state.sync_map
      local current = vim.api.nvim_get_current_win()
      pcall(function()
        if current == M.state.left_win and vim.api.nvim_win_is_valid(M.state.right_win) then
          local info = vim.fn.getwininfo(M.state.left_win)[1]
          local topline = info and info.topline or 1
          local visual = topline + (map.left_cum[topline] or 0)
          local target = visual_to_line(visual, map.right_cum, map.right_count)
          vim.api.nvim_win_call(M.state.right_win, function()
            vim.fn.winrestview({ topline = target })
          end)
        elseif current == M.state.right_win and vim.api.nvim_win_is_valid(M.state.left_win) then
          local info = vim.fn.getwininfo(M.state.right_win)[1]
          local topline = info and info.topline or 1
          local visual = topline + (map.right_cum[topline] or 0)
          local target = visual_to_line(visual, map.left_cum, map.left_count)
          vim.api.nvim_win_call(M.state.left_win, function()
            vim.fn.winrestview({ topline = target })
          end)
        end
      end)
      M.state.syncing = false
    end,
  })
end

local function set_buf_lines(buf, lines)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
end

local function clear_decorations(buf, ns)
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
end

local function render_diff(file)
  local rows = file.rows or {}

  local left_lines, right_lines = {}, {}
  local row_to_left, row_to_right = {}, {}
  local left_fillers_before, right_fillers_before = {}, {}
  local left_idx, right_idx = 0, 0
  local left_pending, right_pending = 0, 0

  for i, row in ipairs(rows) do
    if row.left.is_filler then
      left_pending = left_pending + 1
    else
      left_idx = left_idx + 1
      left_lines[left_idx] = row.left.content
      left_fillers_before[left_idx] = left_pending
      left_pending = 0
      row_to_left[i] = left_idx
    end
    if row.right.is_filler then
      right_pending = right_pending + 1
    else
      right_idx = right_idx + 1
      right_lines[right_idx] = row.right.content
      right_fillers_before[right_idx] = right_pending
      right_pending = 0
      row_to_right[i] = right_idx
    end
  end

  local left_cum, right_cum = {}, {}
  local cum = 0
  for i = 1, #left_lines do
    cum = cum + (left_fillers_before[i] or 0)
    left_cum[i] = cum
  end
  cum = 0
  for i = 1, #right_lines do
    cum = cum + (right_fillers_before[i] or 0)
    right_cum[i] = cum
  end
  M.state.sync_map = {
    left_cum = left_cum, right_cum = right_cum,
    left_count = #left_lines, right_count = #right_lines,
  }

  -- Decide right pane buffer mode. When to_commit is the current `@`,
  -- swap in the real worktree file so LSP/treesitter/edits work.
  local current_at = jj.commit_full("@", M.state.root)
  local use_real = (M.state.to_commit and current_at and M.state.to_commit == current_at)

  -- Clear extmarks on the previous right_buf (if any).
  if M.state.right_buf and vim.api.nvim_buf_is_valid(M.state.right_buf) then
    pcall(vim.api.nvim_buf_clear_namespace, M.state.right_buf, RIGHT_NS, 0, -1)
  end

  if use_real then
    local abs = M.state.root .. "/" .. file.path
    local preexisting = vim.fn.bufnr(abs) ~= -1
    if M.state.right_win and vim.api.nvim_win_is_valid(M.state.right_win) then
      vim.api.nvim_win_call(M.state.right_win, function()
        vim.cmd("edit " .. vim.fn.fnameescape(abs))
      end)
      M.state.right_buf = vim.api.nvim_win_get_buf(M.state.right_win)
      if M.state.decorated_real_bufs[M.state.right_buf] == nil then
        M.state.decorated_real_bufs[M.state.right_buf] = {
          prev_modifiable = vim.bo[M.state.right_buf].modifiable,
          was_preexisting = preexisting,
        }
      end
      -- Explicit reload from disk: bypass vim's autoread/edit! caching.
      local ok, disk_lines = pcall(vim.fn.readfile, abs, "b")
      if ok and disk_lines then
        vim.bo[M.state.right_buf].modifiable = true
        vim.api.nvim_buf_set_lines(M.state.right_buf, 0, -1, false, disk_lines)
        vim.bo[M.state.right_buf].modified = false
      end
      vim.bo[M.state.right_buf].modifiable = false
      setup_diff_pane(M.state.right_win)
    end
  else
    -- Restore scratch buffer if we switched away from it.
    local sb = M.state.scratch_right_buf
    if not sb or not vim.api.nvim_buf_is_valid(sb) then
      sb = vim.api.nvim_create_buf(false, true)
      vim.bo[sb].buftype = "nofile"
      vim.bo[sb].swapfile = false
      vim.bo[sb].bufhidden = "hide"
      M.state.scratch_right_buf = sb
    end
    if vim.api.nvim_win_get_buf(M.state.right_win) ~= sb then
      vim.api.nvim_win_set_buf(M.state.right_win, sb)
    end
    M.state.right_buf = sb
    setup_diff_pane(M.state.right_win)
  end

  set_buf_lines(M.state.left_buf, left_lines)
  if not use_real then
    set_buf_lines(M.state.right_buf, right_lines)
  end

  local from_short = (M.state.from_commit or ""):sub(1, 12)
  pcall(vim.api.nvim_buf_set_name, M.state.left_buf,
    ("notes-v2://%s/%s"):format(from_short, file.path))
  if not use_real then
    local to_short = (M.state.to_commit or ""):sub(1, 12)
    pcall(vim.api.nvim_buf_set_name, M.state.right_buf,
      ("notes-v2://%s/%s"):format(to_short, file.path))
  end

  local ft = FILETYPES[file.language] or vim.filetype.match({ filename = file.path })
  if ft then
    vim.bo[M.state.left_buf].filetype = ft
    ensure_treesitter(M.state.left_buf, ft)
    vim.bo[M.state.right_buf].filetype = ft
    ensure_treesitter(M.state.right_buf, ft)
  end

  vim.b[M.state.left_buf][ANCHOR_VAR] = M.state.from_commit
  vim.b[M.state.left_buf][PATH_VAR] = file.path
  vim.b[M.state.left_buf][ROOT_VAR] = M.state.root
  vim.b[M.state.right_buf][ANCHOR_VAR] = M.state.to_commit
  vim.b[M.state.right_buf][PATH_VAR] = file.path
  vim.b[M.state.right_buf][ROOT_VAR] = M.state.root

  clear_decorations(M.state.left_buf, LEFT_NS)
  clear_decorations(M.state.right_buf, RIGHT_NS)

  for i, row in ipairs(rows) do
    local lr = row_to_left[i]
    if lr then
      for _, hl in ipairs(row.left.highlights) do
        vim.api.nvim_buf_set_extmark(M.state.left_buf, LEFT_NS, lr - 1, hl.start, {
          end_col = hl["end"], hl_group = "DifftRemoved",
        })
      end
    end
    local rr = row_to_right[i]
    if rr and rr <= vim.api.nvim_buf_line_count(M.state.right_buf) then
      for _, hl in ipairs(row.right.highlights) do
        pcall(vim.api.nvim_buf_set_extmark, M.state.right_buf, RIGHT_NS, rr - 1, hl.start, {
          end_col = hl["end"], hl_group = "DifftAdded",
        })
      end
    end
  end

  local filler_virt = { { string.rep("╱", 300), "DifftFiller" } }
  for real_line, count in pairs(left_fillers_before) do
    if count > 0 then
      local vlines = {}
      for _ = 1, count do vlines[#vlines + 1] = filler_virt end
      vim.api.nvim_buf_set_extmark(M.state.left_buf, LEFT_NS, real_line - 1, 0, {
        virt_lines_above = true, virt_lines = vlines,
      })
    end
  end
  local right_buf_lines = vim.api.nvim_buf_line_count(M.state.right_buf)
  for real_line, count in pairs(right_fillers_before) do
    if count > 0 and real_line <= right_buf_lines then
      local vlines = {}
      for _ = 1, count do vlines[#vlines + 1] = filler_virt end
      vim.api.nvim_buf_set_extmark(M.state.right_buf, RIGHT_NS, real_line - 1, 0, {
        virt_lines_above = true, virt_lines = vlines,
      })
    end
  end

  M.state.hunk_positions_left = {}
  M.state.hunk_positions_right = {}
  for _, row_pos in ipairs(file.hunk_starts or {}) do
    local rp = row_pos + 1
    for j = rp, #rows do
      if row_to_left[j] then
        table.insert(M.state.hunk_positions_left, row_to_left[j])
        break
      end
    end
    for j = rp, #rows do
      if row_to_right[j] then
        table.insert(M.state.hunk_positions_right, row_to_right[j])
        break
      end
    end
  end

  setup_scroll_sync()

  vim.api.nvim_set_current_win(M.state.right_win)
  safe_set_cursor(M.state.left_win, { 1, 0 })
  safe_set_cursor(M.state.right_win, { 1, 0 })

  pcall(require("notes-v2.render").render, M.state.left_buf)
  pcall(require("notes-v2.render").render, M.state.right_buf)
end

function M.anchor_for(bufnr)
  bufnr = bufnr or 0
  local ok_c, commit = pcall(vim.api.nvim_buf_get_var, bufnr, ANCHOR_VAR)
  if not ok_c or not commit then return nil end
  local _, path = pcall(vim.api.nvim_buf_get_var, bufnr, PATH_VAR)
  local _, root = pcall(vim.api.nvim_buf_get_var, bufnr, ROOT_VAR)
  return { commit = commit, path = path, root = root }
end

function M.is_review_buffer(bufnr)
  return M.anchor_for(bufnr) ~= nil
end

local function build_tree_lines()
  local NuiLine = require("nui.line")
  local lines, map = {}, {}
  if #M.state.files == 0 then
    local l = NuiLine()
    l:append("  (no files in this snapshot diff)", "Comment")
    table.insert(lines, l)
    return lines, map
  end
  for i, f in ipairs(M.state.files) do
    local l = NuiLine()
    local marker = (f.path == M.state.current_file) and "▶ " or "  "
    l:append(marker)
    l:append(f.kind, KIND_HL[f.kind] or "Comment")
    l:append("  ")
    l:append(f.path, "Normal")
    table.insert(lines, l)
    map[i] = f
  end
  return lines, map
end

local function render_tree()
  if not M.state.tree_buf or not vim.api.nvim_buf_is_valid(M.state.tree_buf) then
    return
  end
  local lines, map = build_tree_lines()
  vim.bo[M.state.tree_buf].modifiable = true
  vim.api.nvim_buf_set_lines(M.state.tree_buf, 0, -1, false,
    vim.tbl_map(function(_) return "" end, lines))
  vim.api.nvim_buf_clear_namespace(M.state.tree_buf, TREE_NS, 0, -1)
  for i, l in ipairs(lines) do
    l:render(M.state.tree_buf, TREE_NS, i)
  end
  vim.bo[M.state.tree_buf].modifiable = false
  M.state.tree_node_map = map
end

local function file_under_tree_cursor()
  if not M.state.tree_win or not vim.api.nvim_win_is_valid(M.state.tree_win) then
    return nil
  end
  local row = vim.api.nvim_win_get_cursor(M.state.tree_win)[1]
  return M.state.tree_node_map[row]
end

local function show_file(file_entry)
  if not file_entry then return end
  M.state.current_file = file_entry.path
  local file, err = diff.compute_file_diff(M.state.from_commit, M.state.to_commit,
    file_entry.path, M.state.root)
  if not file then
    vim.notify("notes-v2: " .. (err or "diff failed for " .. file_entry.path),
      vim.log.levels.WARN)
    return
  end
  render_diff(file)
  render_tree()
end

function M.next_hunk()
  local positions = M.state.hunk_positions_right
  local win = M.state.right_win
  if vim.api.nvim_get_current_win() == M.state.left_win then
    positions = M.state.hunk_positions_left
    win = M.state.left_win
  end
  if not win or #positions == 0 then return end
  local line = vim.api.nvim_win_get_cursor(win)[1]
  for _, pos in ipairs(positions) do
    if pos > line then safe_set_cursor(win, { pos, 0 }); return end
  end
end

function M.prev_hunk()
  local positions = M.state.hunk_positions_right
  local win = M.state.right_win
  if vim.api.nvim_get_current_win() == M.state.left_win then
    positions = M.state.hunk_positions_left
    win = M.state.left_win
  end
  if not win or #positions == 0 then return end
  local line = vim.api.nvim_win_get_cursor(win)[1]
  for i = #positions, 1, -1 do
    if positions[i] < line then safe_set_cursor(win, { positions[i], 0 }); return end
  end
end

local function attach_tree_keymaps()
  local opts = { buffer = M.state.tree_buf, nowait = true, silent = true }
  vim.keymap.set("n", "<CR>", function()
    show_file(file_under_tree_cursor())
  end, opts)
  vim.keymap.set("n", "o", function()
    show_file(file_under_tree_cursor())
  end, opts)
  vim.keymap.set("n", "q", function() M.close() end, opts)
end

function M.is_open()
  return M.state.tabpage and vim.api.nvim_tabpage_is_valid(M.state.tabpage)
end

local function pick_from_commit(root)
  -- Prefer the most recently approved commit as the diff baseline — that
  -- represents "the last state I OK'd". Fallback: previous evolog entry.
  local approved = lock.approved_commits(root)
  if approved and #approved > 0 then
    return approved[#approved]
  end
  local evo = jj.evolog_commits(root)
  return evo[2]
end

function M.refresh()
  if not M.is_open() then return end
  -- Always show "current @ vs last-approved (or previous evolog entry)".
  local current_at = jj.commit_full("@", M.state.root)
  if current_at then M.state.to_commit = current_at end
  local from = pick_from_commit(M.state.root)
  if from then M.state.from_commit = from end
  M.state.files = jj.diff_summary(M.state.from_commit, M.state.to_commit, M.state.root)
  render_tree()
  if M.state.current_file then
    local still_there = false
    for _, f in ipairs(M.state.files) do
      if f.path == M.state.current_file then still_there = true; break end
    end
    if still_there then
      show_file({ path = M.state.current_file })
    elseif #M.state.files > 0 then
      show_file(M.state.files[1])
    end
  end
end

function M.open(opts)
  opts = opts or {}
  if M.is_open() then
    vim.api.nvim_set_current_tabpage(M.state.tabpage)
    M.refresh()
    return
  end

  local root = opts.root or jj.workspace_root(vim.fn.getcwd())
  if not root then
    vim.notify("notes-v2: not in a jj workspace", vim.log.levels.WARN)
    return
  end

  local to_commit = opts.to or jj.commit_full("@", root)
  local from_commit = opts.from or pick_from_commit(root)
  if not from_commit then
    vim.notify("notes-v2: no baseline to diff against (approve a commit first or wait for snapshots)",
      vim.log.levels.WARN)
    return
  end

  local files = jj.diff_summary(from_commit, to_commit, root)
  if #files == 0 then
    vim.notify("notes-v2: no file changes in this snapshot",
      vim.log.levels.INFO)
    return
  end

  M.state.origin_tabpage = vim.api.nvim_get_current_tabpage()
  M.state.root = root
  M.state.from_commit = from_commit
  M.state.to_commit = to_commit
  M.state.files = files

  vim.cmd("tabnew")
  M.state.tabpage = vim.api.nvim_get_current_tabpage()

  M.state.left_win = vim.api.nvim_get_current_win()
  M.state.left_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(M.state.left_win, M.state.left_buf)
  vim.bo[M.state.left_buf].buftype = "nofile"
  vim.bo[M.state.left_buf].swapfile = false
  vim.bo[M.state.left_buf].bufhidden = "wipe"
  setup_diff_pane(M.state.left_win)

  vim.cmd("vsplit")
  M.state.right_win = vim.api.nvim_get_current_win()
  M.state.scratch_right_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(M.state.right_win, M.state.scratch_right_buf)
  vim.bo[M.state.scratch_right_buf].buftype = "nofile"
  vim.bo[M.state.scratch_right_buf].swapfile = false
  vim.bo[M.state.scratch_right_buf].bufhidden = "hide"
  M.state.right_buf = M.state.scratch_right_buf
  setup_diff_pane(M.state.right_win)

  local Split = require("nui.split")
  M.state.tree_split = Split({
    relative = "editor",
    position = "bottom",
    size = "25%",
    enter = false,
    buf_options = {
      buftype = "nofile", modifiable = false,
      filetype = "notes-v2-review-tree",
    },
    win_options = {
      number = false, relativenumber = false,
      signcolumn = "no", winfixheight = true,
      cursorline = true, wrap = false,
    },
  })
  M.state.tree_split:mount()
  M.state.tree_win = M.state.tree_split.winid
  M.state.tree_buf = M.state.tree_split.bufnr
  pcall(vim.api.nvim_buf_set_name, M.state.tree_buf, "[notes-v2 files]")

  attach_tree_keymaps()

  local target_path = opts.path
  local first = files[1]
  if target_path then
    for _, f in ipairs(files) do
      if f.path == target_path then first = f; break end
    end
  end
  show_file(first)
  vim.api.nvim_set_current_win(M.state.tree_win)
end

function M.open_diff(opts)
  M.open(opts)
end

function M.close()
  if M.state.scroll_augroup then
    pcall(vim.api.nvim_del_augroup_by_id, M.state.scroll_augroup)
  end
  -- Clean up real worktree buffers we touched. If we opened the buffer
  -- for the review (it didn't exist before), wipe it. Otherwise strip our
  -- decorations and restore its original `modifiable` state.
  for buf, info in pairs(M.state.decorated_real_bufs or {}) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_clear_namespace, buf, RIGHT_NS, 0, -1)
      pcall(function() vim.b[buf][ANCHOR_VAR] = nil end)
      pcall(function() vim.b[buf][PATH_VAR] = nil end)
      pcall(function() vim.b[buf][ROOT_VAR] = nil end)
      if info.was_preexisting then
        pcall(function() vim.bo[buf].modifiable = info.prev_modifiable end)
      else
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end
  end
  if M.state.scratch_right_buf and vim.api.nvim_buf_is_valid(M.state.scratch_right_buf) then
    pcall(vim.api.nvim_buf_delete, M.state.scratch_right_buf, { force = true })
  end
  if M.state.tree_split then
    pcall(function() M.state.tree_split:unmount() end)
  end
  local origin = M.state.origin_tabpage
  local diff_tab = M.state.tabpage
  M.state = {
    tabpage = nil, origin_tabpage = nil,
    left_win = nil, left_buf = nil,
    right_win = nil, right_buf = nil,
    scratch_right_buf = nil,
    tree_split = nil, tree_win = nil, tree_buf = nil,
    from_commit = nil, to_commit = nil, root = nil,
    files = {}, tree_node_map = {}, current_file = nil,
    hunk_positions_left = {}, hunk_positions_right = {},
    scroll_augroup = nil, syncing = false, sync_map = nil,
    decorated_real_bufs = {},
  }
  if origin and vim.api.nvim_tabpage_is_valid(origin) then
    pcall(vim.api.nvim_set_current_tabpage, origin)
  end
  if diff_tab and vim.api.nvim_tabpage_is_valid(diff_tab) then
    local nr = vim.api.nvim_tabpage_get_number(diff_tab)
    pcall(vim.cmd, "tabclose " .. nr)
  end
end

return M
