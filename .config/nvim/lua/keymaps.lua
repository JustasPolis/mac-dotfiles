local opts = { silent = true }

local keys = {
    ["\27[49;5u"] = "<C-1>",
    ["\27[50;5u"] = "<C-2>",
    ["\27[51;5u"] = "<C-3>",
    ["\27[52;5u"] = "<C-4>",
    ["\27[53;5u"] = "<C-5>",
}
for code, mapping in pairs(keys) do
    vim.keymap.set("n", code, mapping, { remap = true, silent = true })
end

vim.keymap.set("", "<Space>", "<Nop>", opts)
vim.keymap.set("n", "<leader>|", ":vnew <cr>", opts)
vim.keymap.set("n", "gb", "<C-o>", opts)
vim.keymap.set("n", "+", ":resize +2<CR>", opts)
vim.keymap.set("n", "_", ":resize -2<CR>", opts)
vim.keymap.set("n", "<A-=>", ":vertical resize +2<CR>", opts)
vim.keymap.set("n", "<A-->", ":vertical resize -2<CR>", opts)
vim.keymap.set("v", "<A-j>", ":m .+1<CR>==", opts)
vim.keymap.set("v", "<A-k>", ":m .-2<CR>==", opts)
vim.keymap.set("v", "p", '"_dP', opts)
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts)
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts)
vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)
vim.keymap.set("n", "<leader>o", ":normal o<CR>", opts)
vim.keymap.set("n", "<leader>O", ":normal O<CR>", opts)
vim.keymap.set("n", "<leader>wf", ":write <CR>", opts)
vim.keymap.set("n", "<leader>wq", ":wqa <CR>", opts)

vim.keymap.set("n", "<ESC>", function()
    for _, win in pairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative ~= "" then
            vim.api.nvim_win_close(win, false)
        end
    end
end, opts)

local function open_tmux_at_root()
    if vim.fn.executable("tmux") == 0 then
        vim.notify("tmux not found", vim.log.levels.WARN)
        return
    end
    local target_dir = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
    vim.fn.jobstart(string.format('tmux display-popup -d "%s" -w 80%% -h 80%% -E', target_dir))
end

vim.keymap.set("n", "<leader>tf", open_tmux_at_root, { desc = "Tmux Popup at Git Root" })

vim.keymap.set("n", "<leader>sf", ":source % <CR>", opts)
