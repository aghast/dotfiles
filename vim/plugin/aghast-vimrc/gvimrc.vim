" $DOTFILES/vim/_gvimrc
"
" Specific settings for graphical Vim clients (gVim, macVim, etc.)
"
" If we have symbolic links, then ~/.gvimrc should be a symlink to
" $DOTFILES/vim/_gvimrc. Otherwise, with no symlinks this file (either
" _gvimrc or .gvimrc) needs to redirect the processing of ~/.gvimrc (by
" sourcing the "real" file) and needs to redirect the location of the ~/.vim
" directory (by modifying runtimepath)
"
echom "gvimrc shellpipe=".&shellpipe
if ! has('gui_running')
    finish
endif

set guioptions-=a   " disable Autoselect (auto copy visual seln to clipboard)
set guioptions-=A   " disable modeless Autoselect (idem)
set guioptions-=T   " disable Toolbar
set guioptions-=m   " disable menubar

colorscheme industry
set background=dark

augroup aghast_gvimrc
    autocmd!
    autocmd GUIEnter * winpos 200 10
augroup END
