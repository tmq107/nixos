-- Configure text-object and jump navigation.
local M = {}

function M.setup(map)
    -- Extend built-in text objects and surroundings.
    require("mini.ai").setup()
    require("mini.surround").setup()

    -- Jump directly to visible locations.
    require("flash").setup()
    map("n", "<leader>j", function()
        require("flash").jump()
    end, { desc = "Jump to location" })
end

return M
