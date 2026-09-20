-- Configure manual code formatting.
local M = {}

function M.setup()
    -- Select formatter by buffer filetype.
    require("conform").setup({
        formatters_by_ft = {
            go = { "gofmt" },
            javascript = { "prettier" },
            javascriptreact = { "prettier" },
            json = { "prettier" },
            lua = { "stylua" },
            markdown = { "prettier" },
            nix = { "alejandra" },
            python = { "black" },
            terraform = { "terraform_fmt" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            yaml = { "prettier" },
        },
    })

    -- Format current buffer on demand.
    vim.api.nvim_create_user_command("Format", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
    end, { desc = "Format current buffer" })
end

return M
