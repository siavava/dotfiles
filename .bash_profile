# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
[[ -f ~/.bashrc ]] && source ~/.bashrc # ghcup-env

# Silence Bash Deprecation Warnings
export BASH_SILENCE_DEPRECATION_WARNING=1

# import settings from bashrc
source ~/.bashrc

# pyenv configuration parameters
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init -)"
fi

######## Add Haskell hlint to PATH #########
export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env"
