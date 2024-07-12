return {
	"lewis6991/gitsigns.nvim",
	lazy = true,
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "│" },
			topdelete = { text = "│" },
			changedelete = { text = "│" },
			untracked = { text = "│" },
		},
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
			delay = 50,
			ignore_whitespace = false,
			virt_text_priority = 100,
		},
		preview_config = {
			border = "rounded",
			style = "minimal",
			relative = "cursor",
			row = 0,
			col = 1,
		},
		on_attach = function(buffer)
			local gs = package.loaded.gitsigns
			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
			end
			map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
			map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
		end,
	},
}
