return {
	"folke/sidekick.nvim",
	opts = {
		nes = {
			enabled = false,
		},
		cli = {
			win = {
				layout = "right",
				split = {
					width = 0.5,
					height = 0,
				},
			},
		},
	},
	keys = {
		{
			"<leader>at",
			function()
				require("sidekick.cli").toggle({ name = "codex", focus = true })
			end,
			desc = "Sidekick Toggle Codex",
		},
	},
}
