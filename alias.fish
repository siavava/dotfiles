#!/usr/bin/env fish
# -*- coding: utf8; -*-

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

# search previous commands
alias search='history | grep'

# redeploy blog
alias redeploy='curl -X POST https://api.netlify.com/build_hooks/658d9d835e2c050092fdfe38'
