return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets", "nvim-tree/nvim-web-devicons", "fang2hou/blink-copilot" },
	version = "1.x",
	opts = {
		keymap = {
			preset = "none",
			["<C-f>"] = { "accept", "fallback" },
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			["<C-Space>"] = { "show", "fallback" },
		},
		cmdline = {
			keymap = { preset = "inherit" },
			completion = { menu = { auto_show = true } },
		},
		completion = {
			ghost_text = { enabled = true, show_with_menu = false },
			documentation = {
				auto_show = false,
				treesitter_highlighting = true,
				draw = function(opts)
					opts.default_implementation()
				end,
			},
			list = { selection = { preselect = true, auto_insert = false }, max_items = 5 },
			menu = {
				auto_show = false,
				border = nil,
				scrollbar = false,
				draw = {
					columns = {
						{ "kind_icon", "label", "label_description", gap = 1 },
						{ "source_name" }, -- shows LSP/Buffer/Path/etc.
					},
				},
			},
		},
		sources = {
			default = { "copilot", "lsp", "path", "snippets", "buffer" },
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					score_offset = 100,
					async = true,
				},
				lsp = { name = "LSP" },
				buffer = { name = "Buffer" },
				path = { name = "Path" },
				snippets = { name = "Snip" },
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},

	opts_extend = { "sources.default" },
}
