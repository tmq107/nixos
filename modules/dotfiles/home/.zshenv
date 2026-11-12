# Key bindings
export KEYTIMEOUT=1
export PATH="$PATH:/opt/local/bin:$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.opencode/bin"

# Pi Env
export PI_FFF_MODE=tools-and-ui
export PI_CODING_AGENT_DIR="$HOME/personal/pi-agent/agent"
export VISUAL="nvim"
export EDITOR="nvim"
export PI_OFFLINE=1

# Browser Setting
if grep -qi microsoft /proc/version 2>/dev/null; then
       export BROWSER="wslview"
fi

# Set Max Ouput
export BASH_MAX_OUTPUT_LENGTH=15000

# Kiro Home
export KIRO_HOME="$HOME/.config/kiro"
