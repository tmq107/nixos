-- Cache Lua modules for faster startup.
vim.loader.enable()

-- Use Space as global mapping prefix.
vim.g.mapleader = " "

-- Enable mouse input.
vim.o.mouse = "a"

-- Show absolute and relative line numbers.
vim.o.number = true
vim.o.relativenumber = true

-- Refresh editor events every 500 ms.
vim.o.updatetime = 500

-- Highlight current cursor line.
vim.opt.cursorline = true

-- Open horizontal and vertical splits predictably.
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Round floating window borders.
vim.o.winborder = "rounded"

-- Ignore case unless search contains uppercase letters.
vim.o.ignorecase = true
vim.o.smartcase = true

-- Update search while typing without persistent highlights.
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Enable 24-bit terminal colors.
vim.opt.termguicolors = true

-- Keep cursor near screen center while moving.
vim.opt.scrolloff = math.max(0, math.floor(vim.o.lines / 2) - 3)

-- Load filetype refresh and focus autocmds.
require("config.autocmds")

-- Install theme before applying it.
vim.pack.add({
    "https://github.com/catppuccin/nvim",
}, { confirm = false })

-- Use Catppuccin Mocha theme.
vim.cmd.colorscheme("catppuccin-mocha")

-- Load remaining plugins after Neovim starts.
vim.schedule(function()
    vim.pack.add({
        -- File search and its Lua dependency.
        "https://github.com/ibhagwan/fzf-lua",
        "https://github.com/nvim-lua/plenary.nvim",

        -- File explorer and its UI dependencies.
        "https://github.com/nvim-neo-tree/neo-tree.nvim",
        "https://github.com/MunifTanjim/nui.nvim",
        "https://github.com/nvim-tree/nvim-web-devicons",

        -- Status line and language tooling.
        "https://github.com/nvim-lualine/lualine.nvim",
        "https://github.com/neovim/nvim-lspconfig",
        { src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1.x") },

        -- Editing, buffers, terminals, and indentation detection.
        "https://github.com/windwp/nvim-autopairs",
        "https://github.com/akinsho/bufferline.nvim",
        "https://github.com/akinsho/toggleterm.nvim",
        "https://github.com/tpope/vim-sleuth",

        -- Text objects, motion, Lua help, syntax, and formatting.
        "https://github.com/echasnovski/mini.nvim",
        "https://github.com/folke/flash.nvim",
        "https://github.com/folke/lazydev.nvim",
        "https://github.com/nvim-treesitter/nvim-treesitter",
        "https://github.com/stevearc/conform.nvim",
    }, { confirm = false })

    -- Share common mappings with plugin setup modules.
    local map = require("config.keymaps")

    -- Configure search/replace and plugin features.
    require("config.replace").setup(map)
    require("plugins.fzf").setup(map)
    require("plugins.explorer").setup(map)
    require("plugins.ui").setup()
    require("plugins.lsp").setup(map)
    require("plugins.editing").setup(map)
    require("plugins.navigation").setup(map)
    require("plugins.lazydev").setup()
    require("plugins.treesitter").setup()
    require("plugins.formatting").setup()
end)
