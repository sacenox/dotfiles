# These are the shared shell configurations, used by zsh on mac and bash on linux.
# to install these please include them at the bottom of your shell's config (zshrc or bashrc)

# Convenience alias:
export EDITOR=nvim

alias n=nvim
alias oc=opencode

alias ll='ls -Fal --color=always'
alias ls='ls --color=always'

alias g='git'
alias gst='git status'
alias gc='git commit --verbose'
alias gp='git pull origin'
alias gpo='git push origin'

alias rg='rg --color always'
alias les='less -r'

# Greetings!
function greet() {
  local cows=(
    "default" "flaming-sheep" "fox" "llama" "sheep" "skeleton" "three-eyes" "tux" "udder" "www"
  )
  local cow=${cows[$RANDOM % ${#cows[@]}]:-"default"}
  fortune -s | cowsay -f $cow -W 80 | lolcat -p 1.0 -F 0.06 -S $(echo $RANDOM)
  # echo "\n cow: $cow" | lolcat -p 1.0 -F 0.06 -S $(echo $RANDOM)  # Show the cow used
}

# Run the greeting function
greet
