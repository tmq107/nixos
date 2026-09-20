-- Configure Lua development completion.
local M = {}

function M.setup()
    -- Add Neovim Lua APIs to completion.
    require("lazydev").setup({})
end

return M
