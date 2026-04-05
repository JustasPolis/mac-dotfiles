local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({
    gh("nvim-treesitter/nvim-treesitter"),
    gh("stevearc/conform.nvim"),
    gh("MunifTanjim/nui.nvim"),

    gh("lewis6991/gitsigns.nvim"),
    gh("folke/snacks.nvim"),
    { src = gh("saghen/blink.cmp"), version = "v1.10.1" },
    gh("nvim-lualine/lualine.nvim"),
    gh("nvim-tree/nvim-web-devicons"),
    gh("L3MON4D3/LuaSnip"),
    gh("rafamadriz/friendly-snippets"),
})
