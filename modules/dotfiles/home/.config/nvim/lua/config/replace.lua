local M = {}

function M.setup(map)
    -- Collect unique files from listed buffers.
    local function collect_files_from_buffers()
        local files = {}
        local seen = {}

        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name ~= "" and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buflisted and not seen[name] then
                seen[name] = true
                table.insert(files, name)
            end
        end

        return files
    end

    -- Recursively collect readable files in a folder.
    local function files_in_folder(folder)
        local files = {}
        for _, path in ipairs(vim.fn.globpath(folder, "**/*", false, true)) do
            if vim.fn.filereadable(path) == 1 then
                table.insert(files, path)
            end
        end
        return files
    end

    -- Return files containing literal search text.
    local function matching_files(paths, search)
        local matched = {}
        local seen = {}

        for _, path in ipairs(paths) do
            local ok, lines = pcall(vim.fn.readfile, path)
            if ok and type(lines) == "table" then
                for _, line in ipairs(lines) do
                    if string.find(line, search, 1, true) then
                        local display = vim.fn.fnamemodify(path, ":.")
                        if not seen[display] then
                            seen[display] = true
                            table.insert(matched, path)
                        end
                        break
                    end
                end
            end
        end

        return matched
    end

    -- Preview, confirm, and save replacements across files.
    local function replace_in_paths(paths, search, replace, scope_label)
        local matched = matching_files(paths, search)
        if #matched == 0 then
            vim.notify("No matches for '" .. search .. "' in " .. scope_label, vim.log.levels.INFO)
            return
        end

        local preview = { string.format("Preview: %d file(s) match in %s", #matched, scope_label) }
        for i, path in ipairs(matched) do
            if i > 10 then
                table.insert(preview, string.format("... and %d more", #matched - 10))
                break
            end
            table.insert(preview, vim.fn.fnamemodify(path, ":."))
        end
        vim.notify(table.concat(preview, "\n"), vim.log.levels.INFO)

        vim.ui.select({ "Apply", "Cancel" }, { prompt = "Apply previewed changes?" }, function(choice)
            if choice ~= "Apply" then
                return
            end

            local changed = {}
            local skipped = {}
            local failed = {}
            local original_win = vim.api.nvim_get_current_win()
            local original_buf = vim.api.nvim_get_current_buf()

            for _, path in ipairs(matched) do
                local ok, err = pcall(function()
                    vim.cmd("keepalt keepjumps edit " .. vim.fn.fnameescape(path))
                    local display = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")

                    if not vim.bo.modifiable or vim.bo.readonly then
                        table.insert(skipped, display)
                        return
                    end

                    local tick = vim.api.nvim_buf_get_changedtick(0)
                    local cmd = string.format(
                        "silent keeppatterns %%s/%s/%s/ge",
                        vim.fn.escape(search, "/\\"),
                        vim.fn.escape(replace, [[/\&%]])
                    )
                    vim.cmd(cmd)

                    if vim.api.nvim_buf_get_changedtick(0) ~= tick then
                        vim.cmd("silent update")
                        table.insert(changed, display)
                    end
                end)

                if not ok then
                    table.insert(failed, path .. ": " .. tostring(err))
                end
            end

            pcall(vim.api.nvim_set_current_win, original_win)
            pcall(vim.api.nvim_set_current_buf, original_buf)

            local lines = {
                string.format("Replaced '%s' with '%s' in %s", search, replace, scope_label),
            }

            if #changed > 0 then
                table.insert(lines, "Changed files: " .. table.concat(changed, ", "))
            end

            if #skipped > 0 then
                table.insert(lines, "Skipped readonly: " .. table.concat(skipped, ", "))
            end

            if #failed > 0 then
                table.insert(lines, "Errors: " .. table.concat(failed, "; "))
            end

            vim.notify(table.concat(lines, "\n"), #failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
        end)
    end

    -- Prompt for replacement text and target scope.
    local function replace_in_all_files()
        vim.ui.input({ prompt = "Search: " }, function(search)
            if not search or search == "" then
                return
            end
            vim.ui.input({ prompt = "Replace: " }, function(replace)
                if replace == nil then
                    return
                end
                vim.ui.select({
                    {
                        label = "Current folder",
                        root = vim.fn.expand("%:p:h"),
                        files = function()
                            return files_in_folder(vim.fn.expand("%:p:h"))
                        end,
                    },
                    {
                        label = "Whole workspace",
                        root = vim.loop.cwd(),
                        files = function()
                            return files_in_folder(vim.loop.cwd())
                        end,
                    },
                    {
                        label = "Open buffers",
                        root = vim.loop.cwd(),
                        files = collect_files_from_buffers,
                    },
                    {
                        label = "Custom folder",
                        root = nil,
                        files = function(folder)
                            return files_in_folder(folder)
                        end,
                        needs_path = true,
                    },
                }, {
                    prompt = "Scope:",
                    format_item = function(item)
                        return item.label
                    end,
                }, function(choice)
                    if not choice then
                        return
                    end
                    local root = choice.root
                    if choice.needs_path then
                        vim.ui.input({ prompt = "Folder: " }, function(folder)
                            if not folder or folder == "" then
                                return
                            end
                            local resolved = vim.fn.fnamemodify(folder, ":p")
                            local files = choice.files and choice.files(resolved) or {}
                            replace_in_paths(
                                files,
                                search,
                                replace,
                                choice.label .. " (" .. vim.fn.fnamemodify(resolved, ":.") .. ")"
                            )
                        end)
                        return
                    end
                    local files = choice.files and choice.files() or {}
                    root = root or vim.loop.cwd()
                    replace_in_paths(
                        files,
                        search,
                        replace,
                        choice.label .. " (" .. vim.fn.fnamemodify(root, ":.") .. ")"
                    )
                end)
            end)
        end)
    end

    -- Prompt for a confirmed replacement in current file.
    local function replace_in_file()
        vim.ui.input({ prompt = "Search: " }, function(search)
            if not search or search == "" then
                return
            end
            vim.ui.input({ prompt = "Replace: " }, function(replace)
                if replace == nil then
                    return
                end
                local cmd =
                    string.format("%%s/\\V%s/%s/gc", vim.fn.escape(search, "/\\"), vim.fn.escape(replace, [[/\&~]]))
                local ok, err = pcall(vim.cmd, cmd)
                if not ok then
                    if tostring(err):match("E486") then
                        vim.notify("No matches found for '" .. search .. "'", vim.log.levels.INFO)
                    else
                        vim.notify(tostring(err), vim.log.levels.ERROR)
                    end
                end
            end)
        end)
    end

    -- Bind file and scoped replacement dialogs.
    map("n", "<C-h>", replace_in_file, { desc = "Find and replace in current file" })
    map("n", "<C-b>h", replace_in_all_files, { desc = "Find and replace with scope picker and preview" })
end

return M
