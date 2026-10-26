# User-local binaries, e.g. npm global installs (prefix is ~/.local, see ~/.npmrc).
# Set before the interactive guard so non-interactive shells see it too.
export PATH="$HOME/.local/bin:$PATH"

[[ $- != *i* ]] && return

# Uncomment to get a nice greeting.
# needs fortune, cowsay, and lolcat installed and in $PATH
#
# greet() {
#   local cows=(
#     "default" "flaming-sheep" "llama" "sheep" "skeleton" "three-eyes" "tux" "udder" "www"
#   )
#   local count=${#cows[@]}
#   local idx
#   if [ -n "${ZSH_VERSION:-}" ]; then
#     idx=$((RANDOM % count + 1))
#   else
#     idx=$((RANDOM % count))
#   fi
#   local cow=${cows[$idx]:-"default"}
#   fortune -s | cowsay -f "$cow" -W 80 | lolcat -p 1.0 -F 0.06 -S "$RANDOM"
# }
# greet

export EDITOR=nvim
alias nv='nvim'
alias vim='nvim'
alias vi='nvim'

alias ls='ls --color'
alias ll='ls -alF'

alias g='git'
alias gst='git status'
alias gc='git commit --verbose'
alias gp='git pull --rebase'
alias gpo='git push origin'

eval "$(fzf --bash)"
eval "$(starship init bash)"

# --- 8< ---

