local M = {}

local uv = vim.uv or vim.loop

math.randomseed(os.time() + (uv.hrtime() % 1000000))

local function rand_hex_chars(n)
  local out = {}
  for i = 1, n do
    out[i] = string.format("%x", math.random(0, 15))
  end
  return table.concat(out)
end

local function ms_now()
  local sec, usec = uv.gettimeofday()
  return sec * 1000 + math.floor(usec / 1000)
end

function M.ulid()
  return string.format("%013x", ms_now()) .. rand_hex_chars(13)
end

function M.now_iso()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function trim_to_title(text, n)
  n = n or 60
  local first = (text or ""):match("^[^\n]*") or ""
  if #first > n then return first:sub(1, n) .. "…" end
  return first
end

function M.thread_init(opts)
  local ev = {
    op = "thread_init",
    ts = M.now_iso(),
    thread_id = opts.thread_id or M.ulid(),
    scope = opts.scope or "line",
    title = opts.title or trim_to_title(opts.body, 60),
  }
  if ev.scope == "line" then
    ev.line = opts.line
    ev.line_end = opts.line_end or opts.line
  end
  return ev
end

function M.message(opts)
  return {
    op = "message",
    ts = M.now_iso(),
    thread_id = opts.thread_id,
    message_id = opts.message_id or M.ulid(),
    author = opts.author,
    body = opts.body,
  }
end

function M.edit(opts)
  return {
    op = "edit",
    ts = M.now_iso(),
    message_id = opts.message_id,
    author = opts.author,
    body = opts.body,
  }
end

function M.delete(opts)
  return {
    op = "delete",
    ts = M.now_iso(),
    message_id = opts.message_id,
    author = opts.author,
  }
end

function M.thread_resolve(opts)
  return {
    op = "thread_resolve",
    ts = M.now_iso(),
    thread_id = opts.thread_id,
  }
end

return M
