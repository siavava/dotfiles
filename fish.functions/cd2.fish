#!/usr/bin/env fish
# -*- encoding: utf-8; -*-

# override cd to highlight current directory.
function cd2
  # echo "ARGV: $argv[1]"
  # echo "$oldcd $argv[1]"
  z "$argv[1]" || return
  printf "\n\033[0;32m%s\033[0m\n" "$(pwd)"
end
