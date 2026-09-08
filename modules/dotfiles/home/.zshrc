# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Plugin manager
source $HOME/.zsh/zinit/zinit.zsh \
    || (git clone --depth 1 https://github.com/zdharma-continuum/zinit.git $HOME/.zsh/zinit && exec zsh)

# Theme
zinit light-mode depth=1 atload="source $HOME/.p10k.zsh" for romkatv/powerlevel10k

# Plugin list
zinit wait lucid light-mode depth=1 nocd for \
    atinit'ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay' zdharma-continuum/fast-syntax-highlighting \
    atload='_zsh_autosuggest_start' zsh-users/zsh-autosuggestions \
    atload='MODE_CURSOR_VIINS="bar"; vim-mode-cursor-init-hook' softmoth/zsh-vim-mode
zinit wait lucid is-snippet for \
    https://github.com/ahmetb/kubectl-aliases/blob/master/.kubectl_aliases \
    https://github.com/ajeetdsouza/zoxide/blob/main/zoxide.plugin.zsh \
    https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh

# Options
setopt \
    autocd \
    autopushd \
    histignorealldups \
    histignorespace \
    sharehistory

# Disable right prompt indent
ZLE_RPROMPT_INDENT=0

# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Reload
fastfetch
source $HOME/.aliases
source $HOME/.funrc

# source sensitive secret that not track in git
[[ -f "$HOME/.zshenv_secret" ]] && source "$HOME/.zshenv_secret"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Force normal path completion for go-task
_task() {
  _files "$@"
}

# SSH Agent
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null 2>&1
fi

compdef _task task

eval "$(direnv hook zsh)"
