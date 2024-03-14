if status is-interactive
  # Commands to run in interactive sessions can go here
  set fish_greeting
end

# gnupg terminal to use
export GPG_TTY=$(tty)

# load homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# zoxide
zoxide init fish | source



############################################
# ALIASES
############################################

# safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# alias '\?'='echo "\e[0;31m$(pwd)\e[0m"'

alias echo 'echo -e'

# friendly `ls`
alias lt='ls -s -F -h -1'
