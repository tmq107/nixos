# Neovim Keymap

> **Leader key: `Space`**

## Modes
| Key | Mode |
|-----|------|
| `i` | Insert mode |
| `Esc` | Normal mode |
| `v` | Visual mode |
| `V` | Visual line mode |
| `:` | Command mode |

## Navigation
| Key | Action |
|-----|--------|
| `h` | Move left |
| `j` | Move down |
| `k` | Move up |
| `l` | Move right |
| `w` | Next word |
| `b` | Previous word |
| `0` | Start of line |
| `$` | End of line |
| `gg` | First line |
| `G` | Last line |
| `Space+Up` | Go to first line (custom) |
| `Space+Down` | Go to last line (custom) |
| `Ctrl+d` | Page down |
| `Ctrl+u` | Page up |
| `{` | Previous paragraph |
| `}` | Next paragraph |

## Edit
| Key | Action |
|-----|--------|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `o` | New line below |
| `O` | New line above |
| `x` | Delete character |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste below |
| `P` | Paste above |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `.` | Repeat last change |
| `cw` | Change word |
| `ciw` | Change inner word |
| `caw` | Change around word |
| `s` | Delete char & insert |
| `S` | Delete line & insert |
| `r` | Replace one character |
| `R` | Replace mode |

## Visual Mode
| Key | Action |
|-----|--------|
| `d` | Delete selection |
| `y` | Copy selection |
| `p` | Paste |
| `>` | Indent |
| `<` | De-indent |
| `Tab` | Indent selection (custom) |
| `Shift+Tab` | Unindent selection (custom) |
| `~` | Toggle case |
| `u` | Lowercase |
| `U` | Uppercase |

## Navigation (Insert Mode, Custom)
| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+Left` | Insert | Go to beginning of line |
| `Ctrl+Right` | Insert | Go to end of line |

## Clipboard (Custom)
| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+c` | Normal, Visual | Copy to clipboard |
| `Ctrl+v` | Normal | Paste from clipboard |
| `Ctrl+v` | Insert | Paste from clipboard (safe paste mode) |
| `Ctrl+v` | Command | Paste from clipboard |

## History (Custom)
| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+z` | Normal | Undo |
| `Ctrl+z` | Insert | Undo and resume insert |
| `Ctrl+y` | Normal | Redo |
| `Ctrl+y` | Insert | Redo and resume insert |

## Selection (Custom)
| Key | Action |
|-----|--------|
| `Ctrl+a` | Select all |

## Save & Quit (Custom)
| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+q` | Normal | Quit |
| `:w` | Command | Save |
| `:q` | Command | Quit |
| `:wq` | Command | Save & quit |
| `:q!` | Command | Force quit (discard changes) |
| `:x` | Command | Save & quit |
| `:qa` | Command | Quit all |

## Diagnostics (Custom)
| Key | Mode | Action |
|-----|------|--------|
| `]d` | Normal | Next diagnostic |
| `[d` | Previous diagnostic |
| `Space+e` | Normal | Show error detail |
| `Space+q` | Normal | Diagnostics to loclist |

## Search
| Key | Action |
|-----|--------|
| `/` | Search forward |
| `?` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `*` | Search word under cursor |
| `#` | Search word under cursor (backward) |
| `:noh` | Clear search highlight |

## Windows & Tabs
| Key | Action |
|-----|--------|
| `:sp` | Split horizontal |
| `:vsp` | Split vertical |
| `Ctrl+w+h` | Move to left window |
| `Ctrl+w+l` | Move to right window |
| `Ctrl+w+j` | Move to below window |
| `Ctrl+w+k` | Move to above window |
| `Ctrl+ww` | Switch windows |
| `:tabnew` | New tab |
| `gt` | Next tab |
| `gT` | Previous tab |
| `:tabclose` | Close tab |

## Comment Toggle (Custom)
| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+/` | Normal | Toggle comment line |
| `Ctrl+/` | Visual | Toggle comment selection |

---

## Plugins

### fzf-lua
| Key | Action |
|-----|--------|
| `Ctrl+p` | Find files |
| `Ctrl+l` | Live grep (search in files) |
| `Ctrl+f` | Fuzzy find in current file (blines) |
| `Esc` | Close fzf-lua |

### Bufferline
| Key | Action |
|-----|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `Space+x` | Close current buffer |

### Find & Replace
| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+h` | Normal | Find and replace in current file (prompts search -> replace, confirms each) |
| `Ctrl+Shift+h` | Normal | Find and replace with scope picker and preview |
| `Space+h` | Normal | Find and replace with scope picker and preview |

**Scope picker:**

| Scope | Meaning |
|-------|---------|
| `Current folder` | Active file folder, recursive |
| `Whole workspace` | Repo root / current working dir, recursive |
| `Open buffers` | All loaded, listed buffers |
| `Custom folder` | Prompt for folder path, recursive |

### Neo-tree (File Explorer)
| Key | Action |
|-----|--------|
| `Ctrl+n` | Open file explorer (reveal left) |
| `Space+n` | Change directory (input prompt) |
| `Esc` (in Neo-tree) | Close Neo-tree window |
| `Enter` / `o` | Open file/directory |
| `a` | Add file/directory |
| `d` | Delete file/directory |
| `r` | Rename |
| `y` | Copy |
| `x` | Cut |
| `p` | Paste |
| `c` | Copy file name |
| `m` | Move file |
| `i` | Toggle hidden files |
| `R` | Refresh |
| `?` | Help |

### Autocompletion -- blink.cmp

> Uses **enter** preset keybindings.

| Key | Action |
|-----|--------|
| `Enter` | Accept completion |
| `Ctrl+n` / `Down` | Next item |
| `Ctrl+p` / `Up` | Previous item |
| `Ctrl+e` | Cancel completion |

### toggleterm

> Direction: float. Terminal persists across hide/show cycles.

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+\` | Normal | Toggle float terminal open/close |
| `Esc` | Terminal | Exit terminal insert mode (back to normal) |
