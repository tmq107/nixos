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

# Sensitive
export CLOUDFLARE_API_TOKEN=$(gopass personal/cloudflare/token)
export GMAIL_OAUTH_CLIENT_ID=$(gopass personal/gmail/oauth_id)
export GMAIL_OAUTH_CLIENT_SECRET=$(gopass personal/gmail/oauth_secret)
export MODELAPI_API_KEY=$(gopass personal/model/api_key)
export MODELAPI_USAGE_API_KEY=$(gopass personal/model/usage_key)
