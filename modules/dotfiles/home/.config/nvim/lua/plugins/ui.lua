-- Configure interface components.
local M = {}

function M.setup()
    -- Detect the active colorscheme for status-line colors.
    require("lualine").setup()
end

return M
