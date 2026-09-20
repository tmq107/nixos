-- Configure file explorer behavior.
local M = {}

function M.setup(map)
    -- Open explorer at current file.
    map("n", "<C-n>", ":Neotree filesystem reveal left<CR>", { desc = "Open file explorer" })
    require("neo-tree").setup({
        window = {
            mappings = {
                ["<esc>"] = "close_window",
            },
        },
        filesystem = {
            use_libuv_file_watcher = true,
            filtered_items = {
                visible = true,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_by_pattern = { "*.log" },
            },
        },
    })

    -- Change current working directory from prompt.
    map("n", "<leader>n", function()
        vim.ui.input({ prompt = "Change dir: " }, function(input)
            if input then
                vim.cmd("cd " .. input)
                vim.cmd("Neotree")
            end
        end)
    end, { desc = "Change explorer directory" })
end

return M
