-- Configure interactive multi-file search and replace.
local M = {}

function M.setup(map)
    map("n", "<C-h>", function()
        require("grug-far").open({ transient = true })
    end, { desc = "Search and replace across files" })
end

return M
