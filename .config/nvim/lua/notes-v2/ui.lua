local M = {}

function M.input(opts, callback)
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.input then
    snacks.input(opts, callback)
    return
  end
  vim.ui.input(opts, callback)
end

return M
