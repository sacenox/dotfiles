export EDITOR=nvim

eval "$(starship init zsh)"
eval "$(fzf --zsh)"

alias ls='ls --color'
alias ll='ls -alF'

alias g='git'
alias gst='git status'
alias gc='git commit --verbose'
alias gp='git pull --rebase'
alias gpo='git push origin'
alias nv='nvim'

alias python='python3'

. "$HOME/.local/bin/env"

export PATH="/opt/homebrew/bin:/opt/homebrew/opt/libpq/bin:$PATH"
eval "$(/opt/homebrew/bin/rbenv init - zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export OPENCODE_API_KEY='{{ OPENCODE_API_KEY }}'
