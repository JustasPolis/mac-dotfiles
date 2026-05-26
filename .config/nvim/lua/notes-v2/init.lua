local M = {}

local store = require("notes-v2.store")
local event_mod = require("notes-v2.event")
local render = require("notes-v2.render")
local window = require("notes-v2.window")
local ui = require("notes-v2.ui")
local jj = require("notes-v2.jj")
local review_window = require("notes-v2.review_window")
local lock = require("notes-v2.lock")

local config = {
  keymap_prefix = "<leader>n",
  author = nil,
}

local function default_author()
  if config.author and config.author ~= "" then return config.author end
  local user = vim.fn.system({ "git", "config", "user.name" })
  user = (user or ""):gsub("\n", "")
  if user == "" then user = vim.env.USER or "user" end
  return user
end

local function notify_warn(msg)
  vim.notify("notes-v2: " .. msg, vim.log.levels.WARN)
end

local function notify_info(msg)
  vim.notify("notes-v2: " .. msg, vim.log.levels.INFO)
end

local function cursor_pos()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  return row, col + 1
end

local function buf_context(bufnr)
  local anchor = review_window.anchor_for(bufnr)
  if anchor and anchor.commit and anchor.path and anchor.root then
    return { root = anchor.root, rel = anchor.path, anchor_commit = anchor.commit }
  end
  local ctx = render.context(bufnr)
  if ctx and ctx.root and ctx.rel then return ctx end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then return nil end
  local abs = vim.fn.fnamemodify(name, ":p")
  local root = jj.workspace_root(vim.fn.fnamemodify(abs, ":h"))
  if not root then return nil end
  if abs:sub(1, #root + 1) ~= root .. "/" then return nil end
  return { root = root, rel = abs:sub(#root + 2) }
end

local function refresh_buf(bufnr, thread_id)
  pcall(render.render, bufnr)
  if window.current_thread_id() == thread_id then
    local ctx = render.context(bufnr)
    if ctx and ctx.state and ctx.state.by_id[thread_id] then
      window.refresh(ctx.state.by_id[thread_id])
    else
      window.close()
    end
  end
end

local function thread_handlers(bufnr, thread_id, anchor_commit, root)
  return {
    on_reply_text = function(thread, text)
      store.append_event(anchor_commit, event_mod.message({
        thread_id = thread.id,
        author = default_author(),
        body = text,
      }), root)
      refresh_buf(bufnr, thread_id)
    end,
    on_edit = function(thread, message_id)
      local ctx = render.context(bufnr)
      local hit = ctx and ctx.state and ctx.state.by_msg_id[message_id]
      if not hit then return end
      ui.input({ prompt = "Edit: ", default = hit.msg.body }, function(text)
        if not text or text == "" or text == hit.msg.body then return end
        store.append_event(anchor_commit, event_mod.edit({
          message_id = message_id,
          author = default_author(),
          body = text,
        }), root)
        refresh_buf(bufnr, thread_id)
      end)
    end,
    on_delete = function(thread, message_id)
      vim.ui.select({ "yes", "no" }, { prompt = "Delete this message?" }, function(choice)
        if choice ~= "yes" then return end
        store.append_event(anchor_commit, event_mod.delete({
          message_id = message_id,
          author = default_author(),
        }), root)
        refresh_buf(bufnr, thread_id)
      end)
    end,
    on_resolve = function(thread)
      store.append_event(anchor_commit, event_mod.thread_resolve({
        thread_id = thread.id,
      }), root)
      refresh_buf(bufnr, thread_id)
    end,
  }
end

local function add_line_thread(bufnr, line_start, line_end)
  local ctx = buf_context(bufnr)
  if not ctx then
    notify_warn("buffer is not in a jj workspace")
    return
  end
  local commit = ctx.anchor_commit or jj.current_commit_id(ctx.root)
  if not commit then
    notify_warn("could not resolve current commit")
    return
  end
  local prompt = (line_start == line_end)
    and ("line thread (line %d): "):format(line_start)
    or ("line thread (lines %d-%d): "):format(line_start, line_end)

  ui.input({ prompt = prompt }, function(text)
    if not text or text == "" then return end
    local init_ev = event_mod.thread_init({
      scope = "line",
      line = line_start,
      line_end = line_end,
      body = text,
    })
    init_ev[store.path_field()] = ctx.rel
    store.append_event(commit, init_ev, ctx.root)
    store.append_event(commit, event_mod.message({
      thread_id = init_ev.thread_id,
      author = default_author(),
      body = text,
    }), ctx.root)
    pcall(render.render, bufnr)
  end)
end

local function add_thread_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = cursor_pos()
  add_line_thread(bufnr, row, row)
end

local function add_range_thread()
  local bufnr = vim.api.nvim_get_current_buf()
  local v_line = vim.fn.line("v")
  local cur_line = vim.fn.line(".")
  local line_start = math.min(v_line, cur_line)
  local line_end = math.max(v_line, cur_line)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
    "n", false
  )
  add_line_thread(bufnr, line_start, line_end)
end

local function pick_thread(threads, prompt, on_choice)
  if #threads == 1 then on_choice(threads[1]); return end
  local titles = vim.tbl_map(function(t) return t.title or "(no title)" end, threads)
  vim.ui.select(titles, { prompt = prompt }, function(_, idx)
    if idx then on_choice(threads[idx]) end
  end)
end

local function open_thread()
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = cursor_pos()
  local threads = render.threads_at_line(bufnr, row)
  if #threads == 0 then
    notify_info("no thread on this line")
    return
  end

  local ctx = render.context(bufnr)
  if not ctx then return end

  pick_thread(threads, "Open thread:", function(thread)
    window.open(thread, {
      source_bufnr = bufnr,
      source_line = row,
      source_col = col - 1,
      handlers = thread_handlers(bufnr, thread.id, thread.commit_id, ctx.root),
    })
  end)
end

local function jump(direction)
  return function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = render.note_lines(bufnr)
    if #lines == 0 then return end
    local row = cursor_pos()
    local target
    if direction == "next" then
      for _, l in ipairs(lines) do
        if l > row then target = l; break end
      end
      target = target or lines[1]
    else
      for i = #lines, 1, -1 do
        if lines[i] < row then target = lines[i]; break end
      end
      target = target or lines[#lines]
    end
    vim.api.nvim_win_set_cursor(0, { target, 0 })
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  local group = vim.api.nvim_create_augroup("notes-v2.nvim", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "FileChangedShellPost" }, {
    group = group,
    callback = function(args)
      pcall(render.render, args.buf)
    end,
  })

  local p = config.keymap_prefix
  vim.keymap.set("n", p .. "a", add_thread_at_cursor,
    { desc = "notes-v2: line thread at cursor" })
  vim.keymap.set("x", p .. "a", add_range_thread,
    { desc = "notes-v2: range thread (visual)" })
  vim.keymap.set("n", p .. "o", open_thread,
    { desc = "notes-v2: open thread at cursor" })
  vim.keymap.set("n", p .. "L", function() pcall(render.render, 0) end,
    { desc = "notes-v2: reload threads" })
  vim.keymap.set("n", p .. "r", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ctx = buf_context(bufnr)
    local root = ctx and ctx.root or jj.workspace_root(vim.fn.getcwd())
    if not root then
      notify_warn("not in a jj workspace")
      return
    end
    if ctx and ctx.rel then
      review_window.open_diff({ root = root, path = ctx.rel })
    else
      review_window.open({ root = root })
    end
  end, { desc = "notes-v2: review window" })
  vim.keymap.set("n", "]n", jump("next"), { desc = "notes-v2: next thread" })
  vim.keymap.set("n", "[n", jump("prev"), { desc = "notes-v2: prev thread" })
  vim.keymap.set("n", "]h", function() review_window.next_hunk() end,
    { desc = "notes-v2: next hunk in review" })
  vim.keymap.set("n", "[h", function() review_window.prev_hunk() end,
    { desc = "notes-v2: prev hunk in review" })

  vim.keymap.set("n", p .. "l", function()
    local root = jj.workspace_root(vim.fn.getcwd())
    if not root then notify_warn("not in a jj workspace"); return end
    local s = lock.status(root)
    notify_info(("%s (%s)"):format(s.locked and "LOCKED" or "unlocked", s.reason))
  end, { desc = "notes-v2: show lock status" })
  vim.keymap.set("n", p .. "A", function()
    local root = jj.workspace_root(vim.fn.getcwd())
    if not root then notify_warn("not in a jj workspace"); return end
    local commit = lock.approve_current(root)
    if commit then
      notify_info("approved " .. commit:sub(1, 12) .. " — agent unblocked")
    end
  end, { desc = "notes-v2: approve current @" })
  vim.keymap.set("n", p .. "U", function()
    local root = jj.workspace_root(vim.fn.getcwd())
    if not root then return end
    local s = lock.status(root)
    if s.reason == "override" then
      lock.clear_override(root)
      notify_info("override cleared")
    else
      lock.set_override(root)
      notify_info("override set — agent unblocked unconditionally")
    end
  end, { desc = "notes-v2: toggle global override" })
end

function M.lock_status(root)
  root = root or jj.workspace_root(vim.fn.getcwd())
  if not root then return { locked = false, reason = "no-workspace" } end
  return lock.status(root)
end

return M
