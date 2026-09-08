vim.loader.enable()

vim.o.mouse = "a"
vim.o.number = true
vim.o.relativenumber = true
vim.g.mapleader = " "

vim.o.updatetime = 500

vim.pack.add({
    "https://github.com/catppuccin/nvim",
}, { confirm = false })

vim.cmd.colorscheme("catppuccin-mocha")

vim.schedule(function()
    vim.pack.add({
        "https://github.com/ibhagwan/fzf-lua",
        "https://github.com/nvim-lua/plenary.nvim",
        "https://github.com/nvim-neo-tree/neo-tree.nvim",
        "https://github.com/MunifTanjim/nui.nvim",
        "https://github.com/nvim-tree/nvim-web-devicons",
        "https://github.com/nvim-lualine/lualine.nvim",
        "https://github.com/neovim/nvim-lspconfig",
        { src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1.x") },
        "https://github.com/windwp/nvim-autopairs",
        "https://github.com/akinsho/bufferline.nvim",
        "https://github.com/akinsho/toggleterm.nvim",
        "https://github.com/tpope/vim-sleuth",
    }, { confirm = false })

    local map = vim.keymap.set

    -- Refresh filetype for new buffers and reopened files
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
        callback = function(args)
            if vim.bo[args.buf].filetype == "" then
                vim.cmd("filetype detect")
            end
        end,
    })

    -- Save/Quit
    map("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit" })

    -- Clipboard
    map("n", "<C-c>", '"+y', { desc = "Copy to clipboard" })
    map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
    map("n", "<C-v>", '"+p', { desc = "Paste from clipboard" })
    map("i", "<C-v>", '<C-g>u<Cmd>set paste<CR><C-r>+<Cmd>set nopaste<CR>', { desc = "Paste from clipboard (Insert mode)" })
    map("c", "<C-v>", "<C-r>+", { desc = "Paste from clipboard (Command mode)" })

    map("i", "<C-Left>",  "<C-o>0", { desc = "Go to beginning of line" })
    map("i", "<C-Right>", "<C-o>$", { desc = "Go to end of line" })

    -- Undo/Redo
    map("n", "<C-z>", "u", { desc = "Undo" })
    map("i", "<C-z>", "<Esc>ui", { desc = "Undo and resume insert" })
    map("n", "<C-y>", "<C-r>", { desc = "Redo" })
    map("i", "<C-y>", "<Esc><C-r>i", { desc = "Redo and resume insert" })

    -- Select All
    map("n", "<C-a>", "ggVG", { desc = "Select All" })

    -- Indent/Unindent with Tab in visual mode
    map("v", "<Tab>", ">gv", { desc = "Indent selection" })
    map("v", "<S-Tab>", "<gv", { desc = "Unindent selection" })

    -- Comment toggle (like VSCode Ctrl+/)
    map("n", "<C-_>", "gcc", { desc = "Toggle comment line", remap = true })
    map("v", "<C-_>", "gc", { desc = "Toggle comment selection", remap = true })

    -- fzf-lua
    require("fzf-lua").setup({
        "max-perf",
        actions = {
            files = {
                ["default"] = function(selected, opts)
                    require("fzf-lua").actions.file_edit(selected, opts)
                    vim.schedule(function()
                        vim.cmd("Neotree reveal")
                    end)
                end,
            },
        },
    })
    map("n", "<C-p>", "<cmd>FzfLua files<CR>", { desc = "Find files" })
    map("n", "<C-l>", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
    map("n", "<C-f>", "<cmd>FzfLua blines<CR>", { desc = "Fuzzy find in current file" })

    -- Find & Replace helpers


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

    local function files_in_folder(folder)
        local files = {}
        for _, path in ipairs(vim.fn.globpath(folder, "**/*", false, true)) do
            if vim.fn.filereadable(path) == 1 then
                table.insert(files, path)
            end
        end
        return files
    end

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
            if choice ~= "Apply" then return end

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
                        vim.fn.escape(search, '/\\'),
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

    local function replace_in_all_files()
        vim.ui.input({ prompt = "Search: " }, function(search)
            if not search or search == "" then return end
            vim.ui.input({ prompt = "Replace: " }, function(replace)
                if replace == nil then return end
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
                    if not choice then return end
                    local root = choice.root
                    if choice.needs_path then
                        vim.ui.input({ prompt = "Folder: " }, function(folder)
                            if not folder or folder == "" then return end
                            local resolved = vim.fn.fnamemodify(folder, ":p")
                            local files = choice.files and choice.files(resolved) or {}
                            replace_in_paths(files, search, replace, choice.label .. " (" .. vim.fn.fnamemodify(resolved, ":.") .. ")")
                        end)
                        return
                    end
                    local files = choice.files and choice.files() or {}
                    root = root or vim.loop.cwd()
                    replace_in_paths(files, search, replace, choice.label .. " (" .. vim.fn.fnamemodify(root, ":.") .. ")")
                end)
            end)
        end)
    end



    local function replace_in_file()
        vim.ui.input({ prompt = "Search: " }, function(search)
            if not search or search == "" then return end
            vim.ui.input({ prompt = "Replace: " }, function(replace)
                if replace == nil then return end
                local cmd = string.format("%%s/\\V%s/%s/gc",
                    vim.fn.escape(search, "/\\"),
                    vim.fn.escape(replace, "/\\")
                )
                vim.cmd(cmd)
            end)
        end)
    end

    map("n", "<C-h>", replace_in_file, { desc = "Find and replace in current file" })
    map("n", "<C-S-h>", replace_in_all_files, { desc = "Find and replace with scope picker and preview" })
    map("n", "<leader>h", replace_in_all_files, { desc = "Find and replace with scope picker and preview" })

    -- Neo-tree
    map("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
    require("neo-tree").setup({
        window = {
            mappings = {
                ["<esc>"] = "close_window",
            },
        },
        filesystem = {
            use_libuv_file_watcher = true,
            filtered_items = {
                visible = true,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_by_pattern = { "*.log" },
            },
        },
    })

    -- Change neo-tree root directory
    map("n", "<leader>n", function()
        vim.ui.input({ prompt = "Change dir: "}, function(input)
            if input then
                vim.cmd("cd " .. input)
                vim.cmd("Neotree")
            end
        end)
    end, { desc = "Neotree change directory" })

    -- Lualine
    require("lualine").setup({
        options = {
            theme = "ayu_dark",
        },
    })

    -- Diagnostics
    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
    })
    map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
    map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show error detail" })
    map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

    -- LSP
    vim.lsp.config("yamlls", {
        settings = {
            yaml = {
                schemas = {
                    ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.yml",
                },
                validate = true,
            },
        },
    })

    vim.lsp.config("gopls", {
        settings = {
            gopls = {
                diagnosticsDelay = "0ms",
            },
        },
    })

    vim.lsp.enable({
        "lua_ls",
        "ts_ls",
        "pyright",
        "gopls",
        "yamlls",
        "markdown_oxide",
    })

    -- terraformls: only activate when .terraform.lock.hcl exists in the file's own directory
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "terraform", "terraform-vars", "hcl" },
        callback = function(args)
            local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":h")
            if vim.fn.filereadable(dir .. "/.terraform.lock.hcl") == 1 then
                vim.lsp.start({
                    name = "terraformls",
                    cmd = { "terraform-ls", "serve" },
                    root_dir = dir,
                }, { bufnr = args.buf })
            end
        end,
    })

    -- blink.cmp (autocompletion)
    require("blink.cmp").setup({
        keymap = { preset = "enter" },
    })

    -- nvim-autopairs
    require("nvim-autopairs").setup()

    -- Bufferline
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
    map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
    map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })

    -- toggleterm
    require("toggleterm").setup({
        size = 15,
        open_mapping = [[<C-\>]],
        direction = "float",
        float_opts = { border = "curved" },
    })
    map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

    -- Navigation
    map("n", "<leader><Up>", "gg", { desc = "Go to first line" })
    map("n", "<leader><Down>", "G", { desc = "Go to last line" })

end)
