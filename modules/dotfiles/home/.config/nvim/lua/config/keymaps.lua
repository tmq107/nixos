-- Use Neovim keymap API.
local map = vim.keymap.set

-- Open command prompt instead of command history.
map("n", "q:", ":", { desc = "Command prompt" })

-- Replace whitespace-only lines before inserting.
for _, key in ipairs({ "i", "a", "A", "I" }) do
    map("n", key, function()
        return vim.fn.getline("."):match("^%s*$") and [["_cc]] or key
    end, { expr = true, desc = "Insert on blank line" })
end

-- Edit words and inspect language-server diagnostics.
map("i", "<C-BS>", "<C-W>", { desc = "Delete previous word" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Quit current window.
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit" })

-- Copy and paste through system clipboard.
map("n", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map("n", "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", "<C-g>u<Cmd>set paste<CR><C-r>+<Cmd>set nopaste<CR>", { desc = "Paste from clipboard" })
map("c", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

-- Move to line edges from Insert mode.
map("i", "<C-Left>", "<C-o>0", { desc = "Go to beginning of line" })
map("i", "<C-Right>", "<C-o>$", { desc = "Go to end of line" })

-- Use familiar undo and redo shortcuts.
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<Esc>ui", { desc = "Undo and resume insert" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })
map("i", "<C-y>", "<Esc><C-r>i", { desc = "Redo and resume insert" })

-- Select entire current buffer.
map("n", "<C-a>", "ggVG", { desc = "Select All" })

-- Keep visual selection after indentation.
map("v", "<Tab>", ">gv", { desc = "Indent selection" })
map("v", "<S-Tab>", "<gv", { desc = "Unindent selection" })

-- Toggle comments with Ctrl-Slash.
map("n", "<C-_>", "gcc", { desc = "Toggle comment line", remap = true })
map("v", "<C-_>", "gc", { desc = "Toggle comment selection", remap = true })

return map
