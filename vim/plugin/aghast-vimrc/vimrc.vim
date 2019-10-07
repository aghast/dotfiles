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

" Set font for gVim
if has("gui_running")
    if has("gui_gtk3")
        set guifont=Noto\ Mono\ Bold\ 13
    elseif has("gui_macvim")
        set guifont=Menlo\ Regular:h14
    elseif has("gui_win32")
        set guifont=Consolas:h15:cANSI
    endif
endif

" }}}

" Configure custom keyboard mappings {{{

let mapleader = ","
let maplocalleader = "\\"

" %% in command mode inserts the path of the current file
:cnoremap %% <C-r>=expand('%:h')<CR>/

" ,eg opens my "real" gvimrc file in a split
execute "nnoremap <Leader>eg	:split " . g:aghast_dot_vim_dir . "/plugin/aghast-vimrc/gvimrc.vim<CR>"

" ,ev opens my "real" vimrc file in a split
execute "nnoremap <Leader>ev	:split " . g:aghast_dot_vim_dir . "/plugin/aghast-vimrc/vimrc.vim<CR>"

" ,sv sources my "real" vimrc file
execute "nnoremap <Leader>sv  :source " . g:aghast_dot_vim_dir . "/plugin/aghast-vimrc/vimrc.vim<CR>"

" ,ed starts opening a file in $DOTFILES
execute "nnoremap <Leader>ed    :split $DOTFILES/<TAB>"

" F12 -> make
nnoremap <F12> :make! test-%<CR>
nnoremap <S-F12> :make! test<CR>

" }}}

" Provide a default value for $DOTFILES {{{

if $DOTFILES ==# ""
    if &verbose > 0
        echom "$DOTFILES is empty. Looking for value."
    endif

    let dotfiles = fnamemodify('~/.dotfiles', ':p')
    if filereadable(dotfiles)
        let lines = readfile(dotfiles)
        for line in lines
            let line = substitute(line, '^\s*\(.*\S\)?\s*$', '\\1', '')

            if line !=# '' && line !~ '^#'
                let $DOTFILES=line
                if &verbose > 0
                    echom "... using $DOTFILES = '".line."'"
                endif
                break
            endif
        endfor
    endif

    if $DOTFILES ==# ""
        if &verbose > 0
            echoerr "$DOTFILES: did not find value in ~/.dotfiles. Still empty."
        endif
    endif
endif
" }}}

" Configuration settings for installed plugins {{{

" LucHermitte/local_vimrc {{{
let g:local_vimrc = [ 'etc', 'vimrc_local.vim']
" }}}

" }}}
"

" Invoke :helptags on all non-$VIM doc directories in runtimepath.
function! s:helptags() abort
  let sep = '/'
  for glob in split(&rtp, ',')
    for dir in map(split(glob(glob), "\n"), 'v:val.sep."/doc/".sep')
      if (dir)[0 : strlen($VIMRUNTIME)] !=# $VIMRUNTIME.sep 
	\ && filewritable(dir) == 2 
	\ && !empty(split(glob(dir.'*.txt'))) 
	\ && (!filereadable(dir.'tags') 
	    \ || filewritable(dir.'tags'))
        silent! execute 'helptags' fnameescape(dir)
      endif
    endfor
  endfor
endfunction

command! -bar Helptags :call s:helptags()

echom "shellpipe=".&shellpipe

