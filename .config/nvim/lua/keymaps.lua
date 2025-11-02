local opts = { noremap = true, silent = true }

local keymap = vim.api.nvim_set_keymap

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
