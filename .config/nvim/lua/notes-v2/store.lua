local M = {}

local NOTES_REF = "review/threads"
local PATH_FIELD = "_path"

local function run(args, opts)
  opts = opts or {}
  return vim.system(args, { cwd = opts.cwd, text = true, stdin = opts.stdin }):wait()
end

local function notes_show(commit, cwd)
  local r = run({ "git", "notes", "--ref=" .. NOTES_REF, "show", commit }, { cwd = cwd })
  if r.code ~= 0 then return nil end
  return r.stdout or ""
end

local function notes_append(commit, line, cwd)
  local r = run(
    { "git", "notes", "--ref=" .. NOTES_REF, "append", "-m", line, commit },
    { cwd = cwd }
  )
  if r.code ~= 0 then
    error("notes-v2: git notes append failed: " .. (r.stderr or ""))
  end
end

local function notes_replace(commit, full_text, cwd)
  local r = run(
    { "git", "notes", "--ref=" .. NOTES_REF, "add", "-f", "-m", full_text, commit },
    { cwd = cwd }
  )
  if r.code ~= 0 then
    error("notes-v2: git notes add -f failed: " .. (r.stderr or ""))
  end
end

local function parse_events(text)
  local events = {}
  if not text then return events end
  for line in text:gmatch("[^\n]+") do
    if line ~= "" then
      local ok, ev = pcall(vim.json.decode, line)
      if ok and type(ev) == "table" and ev.op then
        table.insert(events, ev)
      end
    end
  end
  return events
end

local function fold_events(events, source_commit)
  local state = { threads = {}, by_id = {}, by_msg_id = {} }
  for _, ev in ipairs(events) do
    if ev.op == "thread_init" then
      local thread = {
        id = ev.thread_id,
        scope = ev.scope or "line",
        line = ev.line,
        line_end = ev.line_end or ev.line,
        title = ev.title,
        status = "open",
        ts = ev.ts,
        commit_id = source_commit,
        path = ev[PATH_FIELD],
        messages = {},
      }
      table.insert(state.threads, thread)
      state.by_id[ev.thread_id] = thread
    elseif ev.op == "message" then
      local thread = state.by_id[ev.thread_id]
      if thread then
        local msg = {
          id = ev.message_id,
          author = ev.author,
          body = ev.body,
          ts = ev.ts,
          deleted = false,
        }
        table.insert(thread.messages, msg)
        state.by_msg_id[ev.message_id] = { thread = thread, msg = msg }
      end
    elseif ev.op == "edit" then
      local hit = state.by_msg_id[ev.message_id]
      if hit then hit.msg.body = ev.body end
    elseif ev.op == "delete" then
      local hit = state.by_msg_id[ev.message_id]
      if hit then hit.msg.deleted = true end
    elseif ev.op == "thread_resolve" then
      local thread = state.by_id[ev.thread_id]
      if thread then
        thread.status = (thread.status == "resolved") and "open" or "resolved"
      end
    end
  end
  return state
end

local function merge_states(states)
  local out = { threads = {}, by_id = {}, by_msg_id = {} }
  for _, s in ipairs(states) do
    for _, t in ipairs(s.threads) do
      if not out.by_id[t.id] then
        table.insert(out.threads, t)
        out.by_id[t.id] = t
      end
    end
    for k, v in pairs(s.by_msg_id) do out.by_msg_id[k] = v end
  end
  return out
end

function M.read_for_commit(commit, cwd)
  local text = notes_show(commit, cwd)
  return fold_events(parse_events(text), commit)
end

function M.read_for_commits(commits, cwd)
  local states = {}
  for _, c in ipairs(commits) do
    local s = M.read_for_commit(c, cwd)
    if #s.threads > 0 then table.insert(states, s) end
  end
  return merge_states(states)
end

function M.append_event(commit, event, cwd)
  local line = vim.json.encode(event)
  notes_append(commit, line, cwd)
end

function M.rewrite_for_commit(commit, events, cwd)
  local lines = {}
  for _, ev in ipairs(events) do
    table.insert(lines, vim.json.encode(ev))
  end
  notes_replace(commit, table.concat(lines, "\n"), cwd)
end

function M.threads_at(state, line_1idx, path)
  local out = {}
  for _, t in ipairs(state.threads) do
    if (not path or t.path == path) and t.scope == "line" and t.line then
      local lend = t.line_end or t.line
      if t.line <= line_1idx and line_1idx <= lend then
        table.insert(out, t)
      end
    end
  end
  return out
end

function M.note_lines(state, path)
  local seen, sorted = {}, {}
  for _, t in ipairs(state.threads) do
    if (not path or t.path == path) and t.scope == "line" and t.line and not seen[t.line] then
      seen[t.line] = true
      table.insert(sorted, t.line)
    end
  end
  table.sort(sorted)
  return sorted
end

function M.path_field()
  return PATH_FIELD
end

function M.notes_ref()
  return NOTES_REF
end

return M
