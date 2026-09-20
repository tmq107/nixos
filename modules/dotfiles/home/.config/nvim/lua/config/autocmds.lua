-- Reset filetype refresh handlers on reload.
local filetype_refresh = vim.api.nvim_create_augroup("FiletypeRefresh", { clear = true })

-- Detect missing filetypes in opened and new buffers
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
    group = filetype_refresh,
    callback = function(args)
        if vim.bo[args.buf].filetype == "" then
            vim.cmd("filetype detect")
        end
    end,
})

-- Reset cursorline focus handlers on reload.
local cursorline = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })

-- Highlight cursor line in focused windows.
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = cursorline,
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

-- Hide cursor line in unfocused windows.
vim.api.nvim_create_autocmd("WinLeave", {
    group = cursorline,
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

-- Save modified Markdown files without touching code buffers.
local markdown_autosave = vim.api.nvim_create_augroup("MarkdownAutosave", { clear = true })

local function save_markdown(buf)
    if
        vim.bo[buf].filetype ~= "markdown"
        or not vim.bo[buf].modified
        or not vim.bo[buf].modifiable
        or vim.bo[buf].readonly
        or vim.bo[buf].buftype ~= ""
        or vim.api.nvim_buf_get_name(buf) == ""
    then
        return
    end

    vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent update")
    end)
end

-- Save after one second without Markdown edits.
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = markdown_autosave,
    callback = function(args)
        if vim.bo[args.buf].filetype ~= "markdown" then
            return
        end

        local changedtick = vim.api.nvim_buf_get_changedtick(args.buf)
        vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(args.buf) and vim.api.nvim_buf_get_changedtick(args.buf) == changedtick then
                save_markdown(args.buf)
            end
        end, 1000)
    end,
})

-- Save Markdown immediately when leaving editing context.
vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave", "FocusLost", "QuitPre" }, {
    group = markdown_autosave,
    callback = function(args)
        save_markdown(args.buf)
    end,
})
