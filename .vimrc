" CS50 recommended .vimrc file

set nocompatible                " Use Vim settings instead of Vi. This must be first!
set backspace=indent,eol,start	" Allow backspacing over everything in insert modee
set history=500			        " Keep 500 lines of command line history
set ruler			        " Show cursor position at all times
set showcmd			        " Display incomplete commands
set incsearch			        " Do incremental searching
set visualbell			        " Flash screen instead of audio cue
set wildmenu			        " Enable tab completion in vim
set tabstop=2			        " Set width and column size of TAB to 4
set softtabstop=2		        " as well as expanding TABS to spaces
set expandtab			        " and setting the indent size to
set shiftwidth=2		        " a width of 4 also
set number			        " Turn line numbering on

" Command for printing date in the file you are editing
map ;D !!date<CR>

" In many terminal emulators the mouse works just fine. Thus, enable it.
if has('mouse')
    set mouse=a
endif

" If terminal supports colors, turn syntax highlighting on.
" Also, highlight the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
endif

if has("autocmd")
    " Turn off auto commenting
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

    " Enable file type detection. Use the default filetype settings so that
    " mail gets 'tw' set to 72, 'cindent' is on in C files, etc.. Also, load
    " indent files to automatically do language-dependant indenting.
    filetype plugin indent on

    " Put these in an autocmd group so that we can delete them easily
    augroup vmrcEx
    au!

    " For all text files set 'textwidth' to 90 characters.
    autocmd FileType text setlocal textwidth=90

    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif

    augroup END
else
    " Set autoindenting on if autocmd is not supported
    set autoindent
endif
