local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})
-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
    vim.opt.statusline = string.rep("─", vim.api.nvim_win_get_width(0))
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = augroup("rust_silent_write"),
  pattern = "*.rs",
  nested = true,
  callback = function()
    vim.cmd([[silent write]])
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
  pattern = { "*.swift", "*.ts", "*.tsx", "*.js", "*.fish", "*.nix" },
  callback = function()
    require("lint").try_lint()
  end,
})

-- vim.api.nvim_create_autocmd("BufWinEnter", {
--   group = vim.api.nvim_create_augroup("help_enter", { clear = true }),
--   pattern = "*",
--   callback = function(event)
--     if vim.bo[event.buf].filetype == "help" then
--       vim.wo[vim.api.nvim_get_current_win()].winfixbuf = true
--     end
--   end,
-- })

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("config_vim_enter", { clear = true }),
  once = true,
  callback = function()
    if vim.fn.argv(0) == "." then
      vim.cmd("Alpha")
    end
  end,
})
