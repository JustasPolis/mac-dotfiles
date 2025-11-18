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
			"<leader>fh",
			function()
				Snacks.picker.highlights()
			end,
			desc = "Highlights",
		},
		{
			"<leader>fe",
			function()
				Snacks.explorer({ focus = "input" })
			end,
			desc = "File Explorer",
		},
		{
			"<leader>ff",
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
			"<leader>fg",
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
			formatters = {
				file = {
					filename_only = true,
				},
			},
			matcher = {
				fuzzy = true,
				ignorecase = true,
			},
			layout = {
				layout = {
					backdrop = true,
					width = 0.999,
					height = 0.999,
					box = "vertical",
					border = true,
					{ win = "input", height = 1, border = "bottom" },
					{ win = "list", border = "none" },
					{ win = "preview", height = 0.80, border = "top" },
				},
			},
			--preset = "vertical",
			--fullscreen = true,
			sources = {
				buffers = {
					sort_lastused = false,
				},
				files = {
					git_status = false,
				},
				explorer = {
					enter = true, -- move focus into the explorer picker
					focus = "input", -- or "input" if you prefer the search box
					diagnostics = false,
					git_status = false,
					layout = { preset = "default" },
					follow_file = true,
					tree = true,
					jump = { close = true },
					auto_close = true,
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
				},
			},
		},
	},
}
