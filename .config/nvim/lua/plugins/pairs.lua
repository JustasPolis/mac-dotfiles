return {
	{
		"nvim-mini/mini.pairs",
		version = "*",
		enable = false,
		config = function()
			require("mini.pairs").setup()
		end,
	},
}
