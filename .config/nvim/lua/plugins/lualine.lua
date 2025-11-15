return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local theme = require("lualine.themes.auto")
		theme.normal.c.bg = "None"
		theme.inactive.c.bg = "None"
		theme.visual.c.bg = "None"
		theme.insert.c.bg = "None"
		theme.replace.c.bg = "None"
		theme.command.c.bg = "None"

		local lualine = require("lualine")
		local file_type = function()
			if vim.bo.filetype == "Trouble" then
				return false
			elseif vim.bo.filetype == "NvimTree" then
				return false
			elseif vim.api.nvim_win_get_config(0).relative == "win" then
				return false
			elseif vim.api.nvim_win_get_config(0).relative == "editor" then
				return false
			else
				return true
			end
		end

		local function hide_in_filetypes(ft_list)
			return function()
				return not vim.tbl_contains(ft_list, vim.bo.filetype)
			end
		end

		local active_lsp_name = function()
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			if next(clients) ~= nil then
				return clients[1].name
			end
		end

		lualine.setup({
			options = {
				icons_enabled = true,
				theme = theme,
				ignore_focus = { "Telescope", "Navigator", "help", "NetrwTreeListing" },
				always_divide_middle = false,
				globalstatus = true,
				refresh = {
					statusline = 100,
				},
				disabled_filetypes = {
					statusline = { "alpha", "fish" },
					winbar = {},
				},
			},
			sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {
					{
						"diagnostics",
						draw_empty = false,
						separator = " ",
						always_visible = false,
						color = { fg = "None", bg = "None" },
						sections = { "error", "warn", "info", "hint" },
						cond = file_type,
						padding = {
							left = 0,
							right = 0,
						},
					},
					{
						active_lsp_name,
						always_visible = false,
						color = { fg = "#FFFFFF", bg = "None" },
						cond = hide_in_filetypes({ "netrw", "Telescope" }),
					},
					{
						"filetype",
						icon_only = true,
						separator = "",
						cond = file_type,
						padding = { left = 0, right = 1 },
						color = { fg = "None", bg = "None" },
					},
					{
						"filename",
						path = 0,
						cond = file_type,
						symbols = { modified = "", readonly = "", unnamed = "" },
						padding = { left = 0, right = 0 },
						color = { fg = "white", bg = "None" },
					},
				},
				lualine_z = {
					{
						"branch",
						always_visible = true,
						icon = { " ", padding = { left = 0, right = 0 }, color = { fg = "#e17792" } },
						color = { fg = "white", bg = "None" },
					},
				},
			},
		})
	end,
}
