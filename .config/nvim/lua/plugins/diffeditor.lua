return {
	"julienvincent/hunk.nvim",
	cmd = { "DiffEditor" },
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("hunk").setup({
			global = {
				quit = { "<leader>q" },
				accept = { "<leader><Cr>" },
				focus_tree = { "<leader>e" },
			},
			tree = {
				expand_node = { "l", "<Right>" },
				collapse_node = { "h", "<Left>" },

				open_file = { "<Cr>" },

				toggle_file = { "a" },
			},
		})
	end,
}
