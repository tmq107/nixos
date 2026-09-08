# Tmux Keymap

## Prefix
| Key | Action |
|-----|--------|
| `Ctrl+Space` | Prefix (custom) |

## Plugins
| Plugin | Description |
|--------|-------------|
| `tmux-yank` | Clipboard yank support |
| `tmux-menus` | Context menus (Prefix + `\`) |

## Sessions
| Key | Action |
|-----|--------|
| `Prefix + d` | Detach from session |
| `Prefix + $` | Rename session |
| `Prefix + s` | List/switch sessions |
| `Prefix + (` | Previous session |
| `Prefix + )` | Next session |

> Attach from terminal: `tmux attach` or `tmux attach -t <name>`
> New named session: `tmux new -s <name>`
> List sessions: `tmux ls`
> Kill session: `tmux kill-session -t <name>`

## Windows & Panes
| Key | Action |
|-----|--------|
| `v` | Split vertical |
| `h` | Split horizontal |
| `c` | New window |
| `Prefix + ,` | Rename window |
| `Prefix + &` | Close window |
| `Prefix + n` | Next window |
| `Prefix + p` | Previous window |
| `Prefix + w` | List windows |
| `Prefix + x` | Close pane |
| `r` | Reload config |

## Navigation
| Key | Action |
|-----|--------|
| `Ctrl+Left` | Navigate to left pane |
| `Ctrl+Right` | Navigate to right pane |
| `Ctrl+Up` | Navigate to upper pane |
| `Ctrl+Down` | Navigate to lower pane |
