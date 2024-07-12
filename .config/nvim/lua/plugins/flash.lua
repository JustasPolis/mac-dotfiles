return {
	"folke/flash.nvim",
	lazy = true,
	opts = {
		search = {
			multi_window = false,
		},
		modes = {
			char = {
				enabled = false,
			},
		},
	},
	keys = {
		{
			"<leader>fs",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},
	},
}
