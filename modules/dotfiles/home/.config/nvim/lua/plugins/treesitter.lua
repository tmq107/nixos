-- Configure parser-based syntax features.
local M = {}

function M.setup()
    -- Enable parser highlighting and indentation.
    require("nvim-treesitter").setup({
        highlight = { enable = true },
        indent = { enable = true },
    })

    -- Install parsers for supported languages.
    require("nvim-treesitter").install({
        "bash",
        "go",
        "hcl",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "nix",
        "python",
        "terraform",
        "tsx",
        "typescript",
        "yaml",
    })
end

return M
