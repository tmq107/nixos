-- Configure interface components.
local M = {}

function M.setup()
    -- Show status with automatic theme selection.
    require("lualine").setup({
        options = {
            theme = "ayu_dark",
        },
    })
end

return M
