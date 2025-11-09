return {
	{
		"nvim-telescope/telescope.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope-ui-select.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				lazy = true,
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
		cmd = "Telescope",
		keys = {
			{
				"<leader>sf",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Telescope find files",
			},
			{
				"<leader>lg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Telescope live grep",
			},
			{
				"<leader>gf",
				function()
					require("telescope.builtin").git_files()
				end,
				desc = "Telescope git files",
			},
			{
				"<leader>sb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Telescope buffers",
			},

			{
				"<leader>so",
				function()
					require("telescope.builtin").grep_string()
				end,
				desc = "Telescope grep string",
			},
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
				defaults = {
					file_ignore_patterns = {
						"node_modules",
						"%.xcodeproj/",
						"%.xcworkspace/",
						"%.xcassets/",
						"%.graphql.swift",
						"%.generated.swift",
					},
					prompt_title = "",
					results_title = "",
					preview_title = "",
					border = true,
					borderchars = {
						prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
						results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
						preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					},
					vimgrep_arguments = {
						"rg",
						"--hidden",
						"--glob",
						"!.git/*",
						"--with-filename",
						"--column",
						"--no-ignore",
					},

					preview = {
						hide_on_startup = false,
					},
					layout_strategy = "vertical",
					layout_config = {
						height = 0.999,
						width = 0.999,
						vertical = {
							preview_cutoff = 0,
						},
					},
				},
			})
			require("telescope").load_extension("fzf")
			require("telescope").load_extension("ui-select")
		end,
	},
}
