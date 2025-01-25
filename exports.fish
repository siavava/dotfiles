#!/usr/bin/env fish
# -*- coding: utf-8 -*-

################################################################################
# bun
################################################################################
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

################################################################################
# ghcup
################################################################################
export PATH="$PATH:$HOME/.ghcup/bin"

################################################################################
# nvm
################################################################################
export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# vscode error fix
# see: https://github.com/conda/conda/issues/13451#issuecomment-1896097903
# export CONDA_PREFIX=$CONDA_ROOT

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/homebrew/anaconda3/bin/conda
  eval /opt/homebrew/anaconda3/bin/conda "shell.fish" "hook" $argv | source
else
  if test -f "/opt/homebrew/anaconda3/etc/fish/conf.d/conda.fish"
      . "/opt/homebrew/anaconda3/etc/fish/conf.d/conda.fish"
  else
      set -x PATH "/opt/homebrew/anaconda3/bin" $PATH
  end
end
# <<< conda initialize <<<
