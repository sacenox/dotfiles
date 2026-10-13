# User-local binaries, e.g. npm global installs (prefix is ~/.local, see ~/.npmrc).
# Set before the interactive guard so non-interactive shells see it too.
export PATH="$HOME/.local/bin:$PATH"

[[ $- != *i* ]] && return

export EDITOR=nvim

alias ls='ls --color'
alias ll='ls -alF'

alias g='git'
alias gst='git status'
alias gc='git commit --verbose'
alias gp='git pull --rebase'
alias gpo='git push origin'

alias nv='nvim'

alias sto='cd {{ paths.storage }}'
alias rep='cd {{ paths.repos }}'

alias vps='ssh {{ vps.user }}@{{ vps.host }}'

export FIRECRAWL_API_KEY='{{ FIRECRAWL_API_KEY }}'
export HOSTINGER_API_KEY='{{ HOSTINGER_API_KEY }}'
export OPENCODE_API_KEY='{{ OPENCODE_API_KEY }}'
export PORKBUN_API_KEY='{{ PORKBUN_API_KEY }}'
export PORKBUN_SECRET_API_KEY='{{ PORKBUN_SECRET_API_KEY }}'

greet() {
  local cows=(
    "default" "flaming-sheep" "fox" "llama" "sheep" "skeleton" "three-eyes" "tux" "udder" "www"
  )
  local count=${#cows[@]}
  local idx
  if [ -n "${ZSH_VERSION:-}" ]; then
    idx=$((RANDOM % count + 1))
  else
    idx=$((RANDOM % count))
  fi
  local cow=${cows[$idx]:-"default"}
  fortune -s | cowsay -f "$cow" -W 80 | lolcat -p 1.0 -F 0.06 -S "$RANDOM"
}
# Uncomment to get a nice greeting.
greet

eval "$(fzf --bash)"
eval "$(starship init bash)"
