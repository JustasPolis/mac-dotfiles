return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{
			"<leader>fd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>fe",
			function()
				Snacks.explorer({ focus = "input" })
			end,
			desc = "File Explorer",
		},
		{
			"<leader>sf",
			function()
				Snacks.picker.files()
			end,
			desc = "Search files",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>lv",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
	},
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = false },
		explorer = { enabled = true },
		indent = { enabled = false },
		input = { enabled = false },
		notifier = { enabled = false },
		quickfile = { enabled = false },
		scope = { enabled = false },
		scroll = { enabled = false },
		statuscolumn = { enabled = false },
		words = { enabled = false },
		picker = {
			sources = {
				explorer = {
					enter = true, -- move focus into the explorer picker
					focus = "input", -- or "input" if you prefer the search box
					diagnostics = false,
					git_status = false,
					layout = { preset = "telescope" },
					follow_file = true,
					tree = true,
					jump = { close = true },
					auto_close = true,
					win = {
						list = {
							keys = {},
						},
						input = {
							keys = {},
						},
					},
				},
				diagnostics = {
					enter = true, -- move focus into the explorer picker
					focus = "list", -- or "input" if you prefer the search box
					diagnostics = false,
					git_status = false,
					follow_file = true,
					tree = true,
					jump = { close = true },
					auto_close = true,
					win = {
						list = {
							keys = {},
						},
						input = {
							keys = {},
						},
					},
				},
			},
		},
	},
}
