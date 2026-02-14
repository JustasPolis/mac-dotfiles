local opts = { noremap = true, silent = true }

local keymap = vim.api.nvim_set_keymap

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

keymap("", "<Space>", "<Nop>", opts)
keymap("n", "<leader>|", ":vnew <cr>", opts)
keymap("n", "gb", "<C-o>", opts)
keymap("n", "+", ":resize +2<CR>", opts)
keymap("n", "_", ":resize -2<CR>", opts)
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)
keymap("n", "<leader>o", ":normal o<CR>", opts)
keymap("n", "<leader>O", ":normal O<CR>", opts)
keymap("n", "<leader>wf", ":write <CR>", opts)
keymap("n", "<leader>wq", ":wqa <CR>", opts)

-- GitLab MR Review
keymap("n", "<leader>gr", ":GitLabReview<CR>", opts)
keymap("n", "<leader>gc", ":GitLabComment<CR>", opts)
keymap("n", "<leader>gi", ":GitLabSessionInfo<CR>", opts)
vim.keymap.set("v", "<space>ai", function()
	return ":CodeCompanion " .. vim.fn.input("message") .. "<cr>"
end, { expr = true })

vim.keymap.set("n", "<ESC>", function()
	for _, win in pairs(vim.api.nvim_list_wins()) do
		if not vim.api.nvim_win_is_valid(win) then
			return
		end

		if
			vim.api.nvim_win_get_config(win).relative == "win"
			or vim.api.nvim_win_get_config(win).relative == "editor"
		then
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, false)
			end
		end
	end
end, opts)

local function open_tmux_at_root()
	local git_root = vim.fs.root(0, { ".git" })

	local target_dir = git_root or vim.fn.getcwd()

	local cmd = string.format('tmux display-popup -d "%s" -w 80%% -h 80%% -E', target_dir)
	vim.fn.jobstart(cmd)
end

vim.keymap.set("n", "<leader>tf", open_tmux_at_root, { desc = "Tmux Popup at Git Root" })

keymap("n", "<leader>sf", ":source % <CR>", opts)
