" vim: set fdm=marker:
"
" Basic setup: nocompat, filetype, syntax {{{
set nocompatible

" Enable filetype detection, filetype plugin execution, and filetype-based 
" indentation
filetype plugin indent on

" Activate syntax hilight, load up the system default hilight files.
syntax on

" }}}

" Configure display settings {{{

set number

if v:version >= 703
    set relativenumber
    set colorcolumn=81
endif

" }}}

" Configure custom keyboard mappings {{{

let mapleader = ","
let maplocalleader = "\\"

" %% in command mode inserts the path of the current file
:cnoremap %% <C-r>=expand('%:h')<CR>/

" ,eg opens my "real" gvimrc file in a split
execute "nnoremap <Leader>eg	:split " . g:aghast_dot_vim_dir . "/gvimrc.vim<CR>"

" ,ev opens my "real" vimrc file in a split
execute "nnoremap <Leader>ev	:split " . g:aghast_dot_vim_dir . "/vimrc.vim<CR>"

" ,sv sources my "real" vimrc file
execute "nnoremap <Leader>sv  :source " . g:aghast_dot_vim_dir . "/plugin/aghast-vimrc/vimrc.vim<CR>"

" ,ed starts opening a file in $DOTFILES
execute "nnoremap <Leader>ed    :split $DOTFILES/<TAB>"

" F12 -> make
nnoremap <F12> :make! test-%<CR>
nnoremap <S-F12> :make! test<CR>

" }}}

" Configuration settings for installed plugins {{{

" LucHermitte/local_vimrc {{{
let g:local_vimrc = [ 'etc', 'vimrc_local.vim']
" }}}

" }}}
"

" Invoke :helptags on all non-$VIM doc directories in runtimepath.
command! -bar Helptags :call aghast#commands#Helptags()
