local M = {}

local Popup = require("nui.popup")
local Layout = require("nui.layout")
local autocmd_event = require("nui.utils.autocmd").event

local current = nil
local drafts = {}

local function save_draft()
  if not current or not current.thread then return end
  local lines = vim.api.nvim_buf_get_lines(current.input.bufnr, 0, -1, false)
  local has_content = false
  for _, l in ipairs(lines) do
    if l ~= "" then has_content = true; break end
  end
  drafts[current.thread.id] = has_content and lines or nil
end

local function close()
  if current then
    save_draft()
    pcall(function() current.layout:unmount() end)
    current = nil
  end
end

local function format_thread(thread)
  local lines = { "# " .. (thread.title or "(no title)"), "" }
  if thread.commit_id then
    table.insert(lines, "*at commit " .. thread.commit_id:sub(1, 12) .. "*")
    table.insert(lines, "")
  end
  local msg_starts = {}
  for i, msg in ipairs(thread.messages or {}) do
    table.insert(msg_starts, { line = #lines + 1, msg_id = msg.id })
    if msg.deleted then
      table.insert(lines, ("*[%s deleted at %s]*"):format(msg.author or "?", msg.ts or "?"))
    else
      local meta = ("**%s** · %s"):format(msg.author or "?", msg.ts or "?")
      table.insert(lines, meta)
      table.insert(lines, "")
      for textline in ((msg.body or "") .. "\n"):gmatch("([^\n]*)\n") do
        table.insert(lines, textline)
      end
    end
    if i < #(thread.messages or {}) then
      table.insert(lines, "")
      table.insert(lines, "---")
      table.insert(lines, "")
    end
  end
  if thread.status == "resolved" then
    table.insert(lines, "")
    table.insert(lines, "*— resolved —*")
  end
  return lines, msg_starts
end

local function msg_at_line(msg_starts, row)
  local hit
  for _, m in ipairs(msg_starts) do
    if m.line <= row then hit = m.msg_id else break end
  end
  return hit
end

local function set_history_lines(popup, lines)
  vim.bo[popup.bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
  vim.bo[popup.bufnr].modifiable = false
  if popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
    pcall(vim.api.nvim_win_set_cursor, popup.winid, { #lines, 0 })
  end
end

local function get_input_text(popup)
  local lines = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
  return vim.trim(table.concat(lines, "\n"))
end

local function clear_input(popup)
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, { "" })
end

local function focus(popup)
  if popup and popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
    vim.api.nvim_set_current_win(popup.winid)
  end
end

local function refresh(thread)
  if not current then return end
  local lines, msg_starts = format_thread(thread)
  set_history_lines(current.history, lines)
  current.thread = thread
  current.msg_starts = msg_starts
end

function M.open(thread, opts)
  opts = opts or {}
  local handlers = opts.handlers or {}
  close()

  local history = Popup({
    enter = false,
    focusable = true,
    border = {
      style = "single",
      text = { top = " thread ", top_align = "center" },
    },
    buf_options = { filetype = "markdown" },
    win_options = {
      wrap = true,
      cursorline = false,
      conceallevel = 2,
      linebreak = true,
    },
  })

  local input = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "single",
      text = { top = " reply ", top_align = "center" },
    },
    buf_options = { filetype = "markdown", modifiable = true },
    win_options = { wrap = true, linebreak = true },
  })

  local layout = Layout(
    { position = "50%", size = { width = "90%", height = "85%" } },
    Layout.Box({
      Layout.Box(history, { size = "60%" }),
      Layout.Box(input, { size = "40%" }),
    }, { dir = "col" })
  )
  layout:mount()

  local lines, msg_starts = format_thread(thread)
  set_history_lines(history, lines)

  if drafts[thread.id] then
    vim.api.nvim_buf_set_lines(input.bufnr, 0, -1, false, drafts[thread.id])
  end

  current = {
    layout = layout,
    history = history,
    input = input,
    thread = thread,
    msg_starts = msg_starts,
    opts = opts,
  }

  local function cur_msg_id()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    return msg_at_line(current.msg_starts, row)
  end

  local function call(name, ...)
    local fn = handlers[name]
    if fn then fn(...) end
  end

  local function submit_reply()
    local text = get_input_text(input)
    if text == "" then return end
    if vim.fn.mode():sub(1, 1) == "i" then vim.cmd("stopinsert") end
    clear_input(input)
    drafts[current.thread.id] = nil
    call("on_reply_text", current.thread, text)
  end

  history:map("n", "q", close, { noremap = true })
  history:map("n", "<C-w>j", function() focus(input) end, { noremap = true })
  history:map("n", "e", function()
    local mid = cur_msg_id()
    if mid then call("on_edit", current.thread, mid) end
  end, { noremap = true })
  history:map("n", "d", function()
    local mid = cur_msg_id()
    if mid then call("on_delete", current.thread, mid) end
  end, { noremap = true })
  history:map("n", "R", function() call("on_resolve", current.thread) end, { noremap = true })
  history:map("n", "gd", function()
    close()
    if opts.source_bufnr and vim.api.nvim_buf_is_valid(opts.source_bufnr) then
      pcall(vim.api.nvim_set_current_buf, opts.source_bufnr)
      if opts.source_line then
        pcall(vim.api.nvim_win_set_cursor, 0, { opts.source_line, opts.source_col or 0 })
      end
    end
  end, { noremap = true })

  input:map("n", "<C-s>", submit_reply, { noremap = true })
  input:map("i", "<C-s>", submit_reply, { noremap = true })
  input:map("n", "<CR>", submit_reply, { noremap = true })
  input:map("n", "<C-w>k", function() focus(history) end, { noremap = true })
  input:map("n", "q", close, { noremap = true })

  history:on(autocmd_event.BufLeave, function()
    vim.defer_fn(function()
      if not current then return end
      local in_history = vim.api.nvim_get_current_win() == history.winid
      local in_input = vim.api.nvim_get_current_win() == input.winid
      if not (in_history or in_input) then close() end
    end, 10)
  end, {})
  input:on(autocmd_event.BufLeave, function()
    vim.defer_fn(function()
      if not current then return end
      local in_history = vim.api.nvim_get_current_win() == history.winid
      local in_input = vim.api.nvim_get_current_win() == input.winid
      if not (in_history or in_input) then close() end
    end, 10)
  end, {})
end

function M.current_thread_id()
  return current and current.thread and current.thread.id
end

M.close = close
M.refresh = refresh

return M
