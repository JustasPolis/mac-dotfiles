return {
	"olimorris/codecompanion.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"ravitemer/mcphub.nvim",
		{ "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
		{
			"echasnovski/mini.diff",
			config = function()
				local diff = require("mini.diff")
				diff.setup({
					source = diff.gen_source.none(),
				})
			end,
		},
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
