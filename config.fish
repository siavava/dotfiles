#!/usr/bin/env fish
# -*- coding: utf-8; -*-

if status is-interactive
  # Commands to run in interactive sessions can go here
  set fish_greeting
end

# gnupg terminal to use
export GPG_TTY=$(tty)

# load homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# aliases
source "alias.fish"

# zoxide
zoxide init fish | source
