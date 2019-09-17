set nocompatible

" Enable filetype detection, filetype plugin execution, and filetype-based 
" indentation
filetype plugin indent on

" Activate syntax hilight, load up the system default hilight files.
syntax on


" Configure custom keyboard mappings

let mapleader = ","

" %% in command mode inserts the path of the current file
:cnoremap %% <C-r>=expand('%:h')<CR>/

" ,ev opens my "real" vimrc file in a split
execute "nnoremap <Leader>ev	:split " . g:aghast_dot_vim_dir . "/plugin/aghast-vimrc/vimrc.vim<CR>"

" ,sv sources my "real" vimrc file
execute "nnoremap <Leader>sv  :source " . g:aghast_dot_vim_dir . "/plugin/aghast-vimrc/vimrc.vim<CR>"

