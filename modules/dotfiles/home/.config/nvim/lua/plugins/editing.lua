-- Configure completion and editing helpers.
local M = {}

function M.setup(map)
    -- Use Enter to confirm completion selections.
    require("blink.cmp").setup({
        keymap = { preset = "enter" },
    })

    -- Insert matching brackets and quotes.
    require("nvim-autopairs").setup()

    -- Show and navigate open buffers.
    require("bufferline").setup({
        options = {
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "File Explorer",
                    highlight = "Directory",
                    separator = true,
                },
            },
        },
    })
    map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
    map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
    map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })

    -- Open a floating terminal window.
    require("toggleterm").setup({
        size = 15,
        open_mapping = [[<C-\>]],
        direction = "float",
        float_opts = { border = "curved" },
    })
    map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

    -- Jump to first or last buffer line.
    map("n", "<leader><Up>", "gg", { desc = "Go to first line" })
    map("n", "<leader><Down>", "G", { desc = "Go to last line" })
end

return M
