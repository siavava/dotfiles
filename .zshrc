# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action
# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=10000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# force zsh to show the complete history
alias history="history 0"

# configure `time` format
TIMEFMT=$'real\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# override default virtualenv indicator in prompt
VIRTUAL_ENV_DISABLE_PROMPT=1
venv_info() {
    [ $VIRTUAL_ENV ] && echo "(%B%F{reset}$(basename $VIRTUAL_ENV)%b%F{%(#.blue.green)})"
}

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    # PROMPT=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)──}$(venv_info)(%B%F{%(#.red.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
    RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'

		# my prompt
		PROMPT=$'\e[0;31mλ> \e[0m'

    # enable syntax-highlighting
    if [ -f $HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && [ "$color_prompt" = yes ]; then
			. $HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
			ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
			ZSH_HIGHLIGHT_STYLES[default]=none
			ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
			ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
			ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
			ZSH_HIGHLIGHT_STYLES[global-alias]=fg=magenta
			ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
			ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
			ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
			ZSH_HIGHLIGHT_STYLES[path]=underline
			ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
			ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
			ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
			ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
			ZSH_HIGHLIGHT_STYLES[command-substitution]=none
			ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
			ZSH_HIGHLIGHT_STYLES[process-substitution]=none
			ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
			ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=magenta
			ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta
			ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
			ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
			ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
			ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
			ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
			ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
			ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
			ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
			ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
			ZSH_HIGHLIGHT_STYLES[assign]=none
			ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
			ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
			ZSH_HIGHLIGHT_STYLES[named-fd]=none
			ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
			ZSH_HIGHLIGHT_STYLES[arg0]=fg=green
			ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
			ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
			ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
			ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
			ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
			ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
			ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%# '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}%n@%m: %~\a'
    ;;
*)
    ;;
esac

new_line_before_prompt=yes
precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Print a new line before the prompt, but only if it is not the first line
    if [ "$new_line_before_prompt" = yes ]; then
      if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
        _NEW_LINE_BEFORE_PROMPT=1
      else
        print ""
      fi
    fi
}

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS sfor completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# enable auto-suggestions based on the history
if [ -f $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#0'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

# source bash  aliases
# why keep parallel running versions of these?
if [[ -r $HOME/.bash_aliases ]]; then
	. $HOME/.bash_aliases
fi



#### CS-50 BASH EXTENSIONS ####
# --------------------------------------------------------------------
# This file includes aliases required and recommended for CS50.
# You should 'source' this file from your ~/.bashrc.
# For more info type `man bash'.
# --------------------------------------------------------------------

# aliases used for cs50 development
alias mygcc='gcc -Wall -pedantic -std=c11 -ggdb'
alias myvalgrind='valgrind --leak-check=full --show-leak-kinds=all'

# aliases for safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# aliases for convenience
alias ls='ls -F --color=auto'
alias mkdir='mkdir -p'
alias which='which -a'

# --------------------------------------------------------------------

# pre-hooks to print PWD on <enter>
# NOTE: Don't work in Bash.
function preexec(){
	cmd=$1
}
function precmd(){
	if [[ "$cmd" ]]; then
		lcmd=$cmd
		cmd=;
	else
		echo -e "\e[0;31m$(pwd)\e[0m"
	fi
}


# configure cargo settings.
# . "$HOME/.cargo/env"

########### DISPLAY (matplotlib) ###########
# add to ~/.bashrc, and source it.
DISPLAY=$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0
export DISPLAY

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env

# addition
bindkey '^I' autosuggest-accept			# autocomplete on TAB
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
 plugins=( [plugins...] zsh-history-substring-search)

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/amittaijoel/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/amittaijoel/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/amittaijoel/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/amittaijoel/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export NVM_DIR="$HOME/.nvm"
export PATH="/usr/local/opt/node@18/bin:$PATH"


# export LUA_PATH="/Users/amittaijoel/torch/install"
. /Users/amittaijoel/torch/install/bin/torch-activate

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/Users/amittaijoel/.bun/_bun" ] && source "/Users/amittaijoel/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

#### ghc
export PATH="$PATH:$HOME/.ghcup/bin"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/siavava/.lmstudio/bin"
