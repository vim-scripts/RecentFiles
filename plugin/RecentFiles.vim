"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" License:   This file is placed in the public domain.
"
" Bartlomiej Podolak <email:  bartlomiej gmail com>
" version 0.5 (2008-02-13)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim version 7+ required
" In viminfo only scalars can be stored so i convert
" list <-> string
"
" Description:
" This script allows you to easly access recently opened files.
" Function RecentFilesList() (with default key binding ',f') displays list of files,
" and allow you to open one by entering its number.
" The list is empty at the begining, it's updated when you open/write files.
"
" Script sets (by default) following key bindings and autocommands:
"  nmap ,f :call RecentFilesList()<cr>
"  au BufReadPost,BufWritePost * call RecentFilesAdd()
"
"
" Installation: Place script  in your plugin directory (i.e: ~/.vim/plugin/)
" NOTE: You must have ! in &viminfo for this script to work.
" Add line:   set viminfo+=!   to your configuration file if necessary.
" You can edit some settings in the SETTINGS section of the script file.

""""""""""""""""""""""""""""""""""" INITIALIZATION AND VERSION CHECK

if &viminfo !~ '!'
    echoerr 'RecentFiles needs the ! parameter in the viminfo option to work correctly.'
    echoerr 'add line:   set viminfo+=!   to your configuration file'
    finish
endif

if v:version < 700
    echoerr 'RecentFiles requires vim version >= 700.'
    finish
endif

if exists("loaded_RecentFiles")
    finish
endif
let loaded_RecentFiles = 1


"""""""""""""""""""""""""""""""""""  SETTINGS

let s:numfiles  = 9           " number of recent filenames stored and displayed
let s:hi_odd    = 'comment'   " highlight group for odd rows
let s:hi_even   = 'string'
let s:prompt    = 'Enter number of file you wish to open> '
let s:dontsave  = [ '/usr/share/vim/vim' ] " filenames matching this regex'es will not be saved

nmap ,f :call RecentFilesList()<cr>
autocmd BufReadPost,BufWritePost * call RecentFilesAdd()


""""""""""""""""""""""""""""""""" DO NOT EDIT ANTYTHING BELOW*
" *) unless you know what you are doing


let s:separator = ',,,'       " filenames separator

"abbreviate RF RecentFiles

" g:RF - string that contains recent filenames separated by s:separator
"        // = join( g:RFLIST, s:separator )
" g:RFLIST - list that contains recent filenames

function! RF2list()
    if exists( 'g:RF' )
        let g:RFLIST = split( g:RF, s:separator )
        if len( g:RFLIST ) > s:numfiles
            let g:RFLIST = g:RFLIST[0 : s:numfiles-1]
            let g:RF     = join( g:RFLIST, s:separator )
        endif
    else
        let g:RFLIST = []
        let g:RF     = ''
    endif
endfunction

" Display recent files list and ask which file to open
function! RecentFilesList()
    call RF2list()
    if len( g:RFLIST ) == 0
        echo "Recent Files List is empty"
        return
    endif
    let l:x = 1

    for item in g:RFLIST
        if l:x % 2 == 1
            exe 'echohl ' . s:hi_odd
        else
            exe 'echohl ' . s:hi_even
        endif
        let item = substitute( item, $HOME, '~', '' )
        echo l:x . ".\t" . item
        let l:x = l:x + 1
    endfor
    echohl None
    let l:answer = input( s:prompt )

    " open file
    if l:answer =~ '^[0-9]\+$' && l:answer > 0 && l:answer <= len( g:RFLIST )
        let l:answer = l:answer - 1
        let filename = substitute( g:RFLIST[l:answer], ' ', '\\ ', 'g' )
        exe "edit ". l:filename

    " delete x entry
    elseif l:answer =~ '^d[0-9]\+$'
        let l:answer = substitute( l:answer, '^d', '', '' )
        if l:answer <= len( g:RFLIST ) - 1
            call remove( g:RFLIST, l:answer - 1 )
            let g:RF = join( g:RFLIST, s:separator )
        endif

    " delete all
    elseif l:answer == 'da'
        let g:RF = ''
        let g:RFLIST = []
    else
        " my favorite case - do nothing
    endif
endfunction


" add file to recent files list
function! RecentFilesAdd()
    call RF2list()
    let l:buf   = expand("%:p")

    for regex in s:dontsave
        if l:buf =~ regex
            return
        endif
    endfor

    let l:index = index( g:RFLIST, l:buf )

    " if there is current filename in the list
    " i'm moving it to front of list
    if l:index != -1
        call remove( g:RFLIST, l:index )
    endif


    " adding file
    let g:RFLIST = [ l:buf ] + g:RFLIST

    if len( g:RFLIST ) > s:numfiles
        let g:RFLIST = g:RFLIST[0 : s:numfiles-1]
    endif
    let g:RF = join( g:RFLIST, s:separator )
endfunction

"eof
