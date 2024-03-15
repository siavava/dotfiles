#!/usr/bin/env fish
# -*- encoding: utf-8; -*-

function c --argument directory
  # echo "ARGV: $argv[1]"
  # echo "$oldcd $argv[1]"
  z $directory || return
  printf "\n\033[0;32m%s\033[0m\n" "$(pwd)"
end
