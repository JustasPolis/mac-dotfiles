require("diffs").setup({
    highlight_mode = "treesitter",
})

vim.api.nvim_create_user_command("Diff", function(opts)
    local arg = vim.trim(opts.args)
    if arg == "" then
        require("diffs").open(nil)
    elseif arg == "staged" then
        require("diffs").open("--staged")
    else
        require("diffs").open(arg)
    end
end, {
    nargs = "?",
    complete = function()
        return { "staged" }
    end,
})
