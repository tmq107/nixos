-- Configure indentation guides.
local M = {}

function M.setup()
    require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true },
    })
end

return M
