return {
	{
		"nvim-mini/mini.pairs",
		version = "*",
		enabled = false,
		config = function()
			require("mini.pairs").setup()
		end,
	},
}
