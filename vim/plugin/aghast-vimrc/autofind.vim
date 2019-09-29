" Automatically ':find' files from the command line, if they do not exist.

function! Buffer_is_empty()
    " If the "last" line is the first line, and the first line is empty...
    return line('$') == 1 && getline(1) == ''
endfunction

function! Find_if_not_exist(path)
    " If the file does not exist, and the current buffer is empty, do a 
    " findfile to locate a file with the correct name, and edit that.
    " (current buffer empty check is because template expansion might 
    " occur for an empty file, and if the user expands a template, they
    " probably wanted that instead).

    let msg_prefix = "autofind(".a:path.") -- "
    if ! Buffer_is_empty()
        " Buffer is not empty - no need to search for an alternative
        echom msg_prefix . "buffer is not empty. Aborted."
        return
    endif
    if ! filereadable(a:path)
        echom msg_prefix . "file missing. Searching..."
        let fpath = findfile(a:path)
        if fpath ==# ''
            echom msg_prefix . "found nothing."
        else
            echom msg_prefix . "found: ".fpath
            let oldbuf = bufnr("%")
            execute ":bwipeout ".oldbuf
            execute ":edit! ".fpath
        endif
    endif
endfunction

augroup aghast_autofind
  autocmd!
  autocmd VimEnter * nested call Find_if_not_exist(expand('<afile>'))
augroup end
