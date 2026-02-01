return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"nvim-tree/nvim-web-devicons",
		"L3MON4D3/LuaSnip",
	},
	version = "1.x",
	opts = {
		snippets = {
			preset = "luasnip",
		},
		keymap = {
			preset = "none",
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			["<Tab>"] = { "show", "cancel", "fallback" },
			["<C-1>"] = {
				function(cmp)
					cmp.accept({ index = 1 })
				end,
			},
			["<C-2>"] = {
				function(cmp)
					cmp.accept({ index = 2 })
				end,
			},
			["<C-3>"] = {
				function(cmp)
					cmp.accept({ index = 3 })
				end,
			},
			["<C-4>"] = {
				function(cmp)
					cmp.accept({ index = 4 })
				end,
			},
			["<C-5>"] = {
				function(cmp)
					cmp.accept({ index = 5 })
				end,
			},
		},
		cmdline = {
			keymap = { preset = "inherit" },
			completion = { menu = { auto_show = true } },
		},
		completion = {
			ghost_text = { enabled = false, show_with_menu = false },
			documentation = {
				auto_show = true,
				treesitter_highlighting = true,
				draw = function(opts)
					opts.default_implementation()
				end,
			},
			list = { selection = { preselect = false, auto_insert = false }, max_items = 5 },
			menu = {
				direction_priority = { "n", "s" },
				max_height = 10,
				min_width = 10,
				auto_show = true,
				border = nil,
				scrollbar = false,
				draw = {
					columns = {
						{ "item_idx" },
						{ "kind_icon", "label", gap = 1 },
						{ "source_name" }, -- shows LSP/Buffer/Path/etc.
					},
					components = {
						item_idx = {
							text = function(ctx)
								return tostring(ctx.idx)
							end,
						},
					},
				},
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				codecompanion = { "codecompanion" },
			},
			providers = {
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
