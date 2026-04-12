local function augroup(name)
    return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        vim.cmd("tabdo wincmd =")
        vim.opt.statusline = string.rep("─", vim.api.nvim_win_get_width(0))
    end,
})


vim.api.nvim_create_autocmd("FileChangedShell", {
    group = augroup("auto_reload"),
    callback = function()
        return true
    end,
})

vim.api.nvim_create_autocmd("FocusGained", {
    group = augroup("checktime"),
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})

local _fs_watchers = {}
local _fs_watch_attached = {}

local function cleanup_fs_watch(buf)
    local entry = _fs_watchers[buf]
    if not entry then
        return
    end

    pcall(entry.handle.stop, entry.handle)
    pcall(entry.handle.close, entry.handle)
    _fs_watchers[buf] = nil
end

vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("fs_watch"),
    callback = function(args)
        local path = vim.api.nvim_buf_get_name(args.buf)
        if path == "" or not vim.uv.fs_stat(path) then
            cleanup_fs_watch(args.buf)
            return
        end

        local entry = _fs_watchers[args.buf]
        if entry and entry.path == path then
            return
        end

        cleanup_fs_watch(args.buf)

        local watcher = vim.uv.new_fs_event()
        if not watcher then return end

        if not pcall(watcher.start, watcher, path, {}, vim.schedule_wrap(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
                vim.api.nvim_buf_call(args.buf, function()
                    vim.cmd("checktime")
                end)
            end
        end)) then
            pcall(watcher.close, watcher)
            return
        end

        _fs_watchers[args.buf] = {
            handle = watcher,
            path = path,
        }

        if _fs_watch_attached[args.buf] then
            return
        end

        _fs_watch_attached[args.buf] = true
        vim.api.nvim_buf_attach(args.buf, false, {
            on_detach = function(_, buf)
                cleanup_fs_watch(buf)
                _fs_watch_attached[buf] = nil
            end,
        })
    end,
})
