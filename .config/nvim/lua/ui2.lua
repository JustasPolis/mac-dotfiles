require('vim._core.ui2').enable({})

vim.api.nvim_create_autocmd('Progress', {
  callback = function(ev)
    local d = ev.data
    if d.status == 'success' or d.status == 'done' then
      vim.fn.system({ 'kitten', 'notify', d.title or 'Done' })
    end
  end,
})
