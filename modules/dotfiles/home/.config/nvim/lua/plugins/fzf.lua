-- Configure fuzzy finder behavior.
local M = {}

-- Exclude generated and version-control files from project search.
local ignored_globs = {
    "!**/.git/**",
    "!**/node_modules/**",
}

local rg_opts = "--hidden --column --line-number --no-heading --color=never --smart-case --glob '"
    .. table.concat(ignored_globs, "' --glob '")
    .. "'"

function M.setup(map)
    -- Search hidden files while excluding configured paths.
    require("fzf-lua").setup({
        "max-perf",
        grep = {
            rg_opts = rg_opts,
        },
        actions = {
            files = {
                ["default"] = function(selected, opts)
                    require("fzf-lua").actions.file_edit(selected, opts)
                    vim.schedule(function()
                        vim.cmd("Neotree reveal")
                    end)
                end,
            },
        },
    })

    -- Search files, project text, and current buffer.
    map("n", "<C-p>", "<cmd>FzfLua files<CR>", { desc = "Find files" })
    map("n", "<C-l>", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
    map("n", "<C-f>", "<cmd>FzfLua blines<CR>", { desc = "Find in current file" })
end

return M
