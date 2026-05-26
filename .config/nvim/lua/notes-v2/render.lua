local M = {}

local store = require("notes-v2.store")
local jj = require("notes-v2.jj")

local NS = vim.api.nvim_create_namespace("notes-v2.nvim")

vim.api.nvim_set_hl(0, "NotesV2Sign", { default = true, link = "DiagnosticSignHint" })
vim.api.nvim_set_hl(0, "NotesV2Resolved", { default = true, link = "Conceal" })

local cache = {}

local function review_anchor(bufnr)
  local ok, rw = pcall(require, "notes-v2.review_window")
  if not ok then return nil end
  return rw.anchor_for(bufnr)
end

local function rel_path(bufnr, cwd)
  local anchor = review_anchor(bufnr)
  if anchor and anchor.path and anchor.root then
    return anchor.path, anchor.root
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then return nil end
  local abs = vim.fn.fnamemodify(name, ":p")
  local root = jj.workspace_root(cwd or vim.fn.fnamemodify(abs, ":h"))
  if root and abs:sub(1, #root + 1) == root .. "/" then
    return abs:sub(#root + 2), root
  end
  return nil
end

local function paint(bufnr, threads)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  -- Sort newest first so dedupe-by-line keeps the freshest thread.
  local sorted = {}
  for _, t in ipairs(threads) do table.insert(sorted, t) end
  table.sort(sorted, function(a, b) return (a.ts or "") > (b.ts or "") end)
  local seen = {}
  for _, thread in ipairs(sorted) do
    local hl = (thread.status == "resolved") and "NotesV2Resolved" or "NotesV2Sign"
    if thread.scope == "line" and thread.line then
      local line_start = thread.line - 1
      local line_end = (thread.line_end or thread.line) - 1
      if line_start >= line_count then
        line_start = math.max(0, line_count - 1)
        line_end = line_start
      elseif line_end >= line_count then
        line_end = line_count - 1
      end
      if not seen[line_start] then
        seen[line_start] = true
        for l = line_start, line_end do
          if l >= 0 and l < line_count then
            local sign_text
            if line_start == line_end then
              sign_text = "💬"
            elseif l == line_start then
              sign_text = "💬"
            elseif l == line_end then
              sign_text = "┗"
            else
              sign_text = "┃"
            end
            vim.api.nvim_buf_set_extmark(bufnr, NS, l, 0, {
              sign_text = sign_text,
              sign_hl_group = hl,
            })
          end
        end
      end
    end
  end
end

function M.render(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)

  local rel, root = rel_path(bufnr)
  if not rel then return end

  local anchor = review_anchor(bufnr)
  local commits
  if anchor and anchor.commit then
    -- Review pane: show threads from any commit in @'s evolog. Reviews
    -- often span multiple snapshots, and threads created earlier in the
    -- session shouldn't disappear when @ advances.
    commits = jj.evolog_commits(root)
    -- Deduplicate while preserving order.
    local seen = {}
    local out = {}
    for _, c in ipairs(commits) do
      if not seen[c] then seen[c] = true; table.insert(out, c) end
    end
    if not seen[anchor.commit] then table.insert(out, anchor.commit) end
    commits = out
  else
    -- Live editor buffer: only threads on current @.
    local current = jj.commit_full("@", root)
    if not current then return end
    commits = { current }
  end
  if not commits or #commits == 0 then return end

  local state = store.read_for_commits(commits, root)
  if not state or #state.threads == 0 then return end

  local relevant = {}
  for _, t in ipairs(state.threads) do
    if t.path == rel then
      table.insert(relevant, t)
    end
  end
  if #relevant == 0 then return end

  cache[bufnr] = { state = state, threads = relevant, root = root, rel = rel, anchor = anchor }
  paint(bufnr, relevant)
end

function M.clear(bufnr)
  bufnr = bufnr or 0
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
  end
  cache[bufnr] = nil
end

function M.threads_at_line(bufnr, line_1idx)
  bufnr = bufnr or 0
  M.render(bufnr)
  local c = cache[bufnr]
  if not c then return {} end
  return store.threads_at({ threads = c.threads }, line_1idx, c.rel)
end

function M.note_lines(bufnr)
  bufnr = bufnr or 0
  local c = cache[bufnr]
  if not c then
    M.render(bufnr)
    c = cache[bufnr]
  end
  if not c then return {} end
  return store.note_lines({ threads = c.threads }, c.rel)
end

function M.context(bufnr)
  bufnr = bufnr or 0
  M.render(bufnr)
  return cache[bufnr]
end

return M
