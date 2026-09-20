-- Configure diagnostics and language servers.
local M = {}

function M.setup(map)
    -- Display and navigate diagnostics.
    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
    })
    map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
    map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show error detail" })
    map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })

    -- Apply GitHub Actions schema to workflow files.
    vim.lsp.config("yamlls", {
        settings = {
            yaml = {
                schemas = {
                    ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.yml",
                },
                validate = true,
            },
        },
    })

    -- Report Go diagnostics without delay.
    vim.lsp.config("gopls", {
        settings = {
            gopls = {
                diagnosticsDelay = "0ms",
            },
        },
    })

    -- Enable language servers installed by Nix.
    vim.lsp.enable({
        "lua_ls",
        "ts_ls",
        "pyright",
        "gopls",
        "yamlls",
        "markdown_oxide",
    })

    -- Start Terraform server only in initialized projects.
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "terraform", "terraform-vars", "hcl" },
        callback = function(args)
            local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":h")
            if vim.fn.filereadable(dir .. "/.terraform.lock.hcl") == 1 then
                vim.lsp.start({
                    name = "terraformls",
                    cmd = { "terraform-ls", "serve" },
                    root_dir = dir,
                }, { bufnr = args.buf })
            end
        end,
    })
end

return M
