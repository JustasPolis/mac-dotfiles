return {
	"olimorris/codecompanion.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"ravitemer/mcphub.nvim",
		{ "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
		"franco-ruggeri/codecompanion-spinner.nvim",
	},
	opts = {
		extensions = {
			spinner = {},
			mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					make_vars = true,
					make_slash_commands = true,
					show_result_in_chat = true,
				},
			},
		},
		display = {
			diff = {
				enabled = true,
				provider = "git_signs", -- mini_diff|split|inline
				provider_opts = {
					-- Options for inline diff provider
					inline = {
						layout = "buffer", -- float|buffer - Where to display the diff
						diff_signs = {
							signs = {
								text = "▌", -- Sign text for normal changes
								reject = "✗", -- Sign text for rejected changes in super_diff
								highlight_groups = {
									addition = "DiagnosticOk",
									deletion = "DiagnosticError",
									modification = "DiagnosticWarn",
								},
							},
							-- Super Diff options
							icons = {
								accepted = " ",
								rejected = " ",
							},
							colors = {
								accepted = "DiagnosticOk",
								rejected = "DiagnosticError",
							},
						},

						opts = {
							context_lines = 3, -- Number of context lines in hunks
							show_dim = true, -- Enable dimming background for floating windows (applies to both diff and super_diff)
							dim = 25, -- Background dim level for floating diff (0-100, [100 full transparent], only applies when layout = "float")
							full_width_removed = true, -- Make removed lines span full width
							show_keymap_hints = true, -- Show "gda: accept | gdr: reject" hints above diff
							show_removed = true, -- Show removed lines as virtual text
						},
					},

					-- Options for the split provider
					split = {
						close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
						layout = "vertical", -- vertical|horizontal split
						opts = {
							"internal",
							"filler",
							"closeoff",
							"algorithm:histogram", -- https://adamj.eu/tech/2024/01/18/git-improve-diff-histogram/
							"indent-heuristic", -- https://blog.k-nut.eu/better-git-diffs
							"followwrap",
							"linematch:120",
						},
					},
				},
				inline = {
					-- If the inline prompt creates a new buffer, how should we display this?
					layout = "vertical", -- vertical|horizontal|buffer
				},
				icons = {
					warning = " ",
				},
			},
			action_palette = {
				width = 95,
				height = 10,
				prompt = "Prompt ", -- Prompt used for interactive LLM calls
				provider = "snacks", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
				opts = {
					show_default_actions = true, -- Show the default actions in the action palette?
					show_default_prompt_library = true, -- Show the default prompt library in the action palette?
					title = "CodeCompanion actions", -- The title of the action palette
				},
			},
		},
		inline = {
			diff = {
				enabled = true,
			},
		},
		strategies = {
			chat = {
				adapter = {
					name = "copilot",
					model = "claude-sonnet-4.5",
				},
				roles = {
					llm = function(adapter)
						return "CodeCompanion (" .. adapter.formatted_name .. ")"
					end,
					user = "Me",
				},
			},
			inline = {
				name = "copilot",
				model = "claude-sonnet-4.5",
			},
		},
	},
}
