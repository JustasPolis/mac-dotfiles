return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets", "nvim-tree/nvim-web-devicons" },
	version = "1.*",
	opts = {
		signature = {
			enabled = true,
		},
		keymap = {
			preset = "none",
			["<C-f>"] = { "accept", "fallback" },
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-k>"] = { "show_signature", "hide_signature", "fallback" }, -- default
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
			list = { selection = { preselect = true, auto_insert = false }, max_items = 10 },
			menu = {
				auto_show = true,
				border = nil,
				scrollbar = false,
				draw = {
					components = {
						kind_icon = {
							ellipsis = false,
							text = function(ctx)
								return ctx.kind_icon .. ctx.icon_gap
							end,
							-- Set the highlight priority to 20000 to beat the cursorline's default priority of 10000
							highlight = function(ctx)
								return { { group = ctx.kind_hl, priority = 20000 } }
							end,
						},

						kind = {
							ellipsis = false,
							width = { fill = true },
							text = function(ctx)
								return ctx.kind
							end,
							highlight = function(ctx)
								return ctx.kind_hl
							end,
						},

						label = {
							width = { fill = true, max = 60 },
							text = function(ctx)
								return ctx.label .. ctx.label_detail
							end,
							highlight = function(ctx)
								-- label and label details
								local highlights = {
									{
										0,
										#ctx.label,
										group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
									},
								}
								if ctx.label_detail then
									table.insert(
										highlights,
										{ #ctx.label, #ctx.label + #ctx.label_detail, group = "BlinkCmpLabelDetail" }
									)
								end

								-- characters matched on the label by the fuzzy matcher
								for _, idx in ipairs(ctx.label_matched_indices) do
									table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
								end

								return highlights
							end,
						},

						label_description = {
							width = { max = 30 },
							text = function(ctx)
								return ctx.label_description
							end,
							highlight = "BlinkCmpLabelDescription",
						},

						source_name = {
							width = { max = 30 },
							text = function(ctx)
								return ctx.source_name
							end,
							highlight = "BlinkCmpSource",
						},

						source_id = {
							width = { max = 30 },
							text = function(ctx)
								return ctx.source_id
							end,
							highlight = "BlinkCmpSource",
						},
					},
				},
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
