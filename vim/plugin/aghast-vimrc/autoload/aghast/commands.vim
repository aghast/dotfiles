" aghast/commands.vim
"
" Abort if not at least VIM 7.0
if v:version < 700
    finish
endif

" Abort if this script is already loaded
if exists("g:loaded_aghast_commands")
    finish
endif

" Remember that this script is already loaded
let g:loaded_aghast_commands = 1

" Save fragile state to be restored at the end of this scriptfile
let s:saved_cpo = &cpo
set cpo&vim

function! aghast#commands#Helptags() abort
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

let &cpo = s:saved_cpo
unlet! s:saved_cpo

