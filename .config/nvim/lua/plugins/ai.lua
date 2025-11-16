return {
	"olimorris/codecompanion.nvim",
	cmd = {
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
		"CodeCompanionToggle",
		"CodeCompanionAdd",
	},
	keys = {
		{
			"<leader>ac",
			function()
				vim.cmd("CodeCompanionChat Toggle")
			end,
			desc = "CodeCompanion chat",
		},
	},
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
	},
	opts = {
		extensions = {
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
			chat = {
				show_settings = true,
				window = {
					layout = "vertical", -- float|vertical|horizontal|buffer
					position = "right", -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
					width = 0.50,
					relative = "editor",
					full_height = true,
					sticky = true, -- chat buffer remains open when switching tabs
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
		tools = {
			["edit"] = "insert_edit_into_file",
			["web"] = "fetch_webpage",
		},
		adapters = {
			acp = {
				gemini_cli = function()
					return require("codecompanion.adapters").extend("gemini_cli", {
						defaults = {
							auth_method = "oauth-personal", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
						},
					})
				end,
				codex = function()
					return require("codecompanion.adapters").extend("codex", {
						defaults = {
							auth_method = "chatgpt", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
						},
					})
				end,
			},
		},
		strategies = {
			chat = {
				keymaps = {
					close = false,
				},
				--adapter = "codex",
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
