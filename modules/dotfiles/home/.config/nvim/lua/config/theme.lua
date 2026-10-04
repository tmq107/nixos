local M = {}

local themes = {
    { name = "Catppuccin Mocha", colorscheme = "catppuccin-mocha" },
    { name = "Kanagawa", colorscheme = "kanagawa" },
    { name = "OneDark Pro", colorscheme = "onedark" },
}

local default_theme = themes[1].colorscheme
local state_file = vim.fn.stdpath("state") .. "/nvim-theme"

local function read_selection()
    local file = io.open(state_file, "r")
    if not file then
        return default_theme
    end

    local selection = file:read("*l")
    file:close()

    for _, theme in ipairs(themes) do
        if theme.colorscheme == selection then
            return selection
        end
    end

    return default_theme
end

local function save_selection(colorscheme)
    vim.fn.mkdir(vim.fn.stdpath("state"), "p")
    local file = io.open(state_file, "w")
    if file then
        file:write(colorscheme, "\n")
        file:close()
    end
end

function M.load()
    local colorscheme = read_selection()
    vim.cmd.colorscheme(colorscheme)
end

function M.setup(map)
    map("n", "<leader>ut", function()
        local choices = {}
        local current_name = "Unknown"
        local current_colorscheme = vim.g.colors_name or read_selection()
        for _, theme in ipairs(themes) do
            table.insert(choices, theme.name)
            if theme.colorscheme == current_colorscheme then
                current_name = theme.name
            end
        end

        vim.ui.select(choices, { prompt = "Current: " .. current_name .. ". Select colorscheme:" }, function(choice)
            if not choice then
                return
            end

            for _, theme in ipairs(themes) do
                if theme.name == choice then
                    vim.cmd.colorscheme(theme.colorscheme)
                    save_selection(theme.colorscheme)
                    return
                end
            end
        end)
    end, { desc = "Choose colorscheme" })
end

return M
