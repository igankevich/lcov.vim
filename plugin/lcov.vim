" VIM plugin for OpenSCAD.
" Maintainer: Ivan Gankevich <igankevich@proton.me>
" License: GPLv3+

if exists("lcov_vim_loaded")
    finish
endif
let lcov_vim_loaded = 1

" read lcov data for the current buffer
function! LcovLoad() abort
	if !exists("g:lcov_vim_file")
        return
    endif
    let filename = expand('%:p')
    if isdirectory(filename)
        return
    endif
    call LcovClear()
    let lines = readfile(g:lcov_vim_file)
    " 0 - finding the file
    " 1 - finding the lines
    let state = 0
    for line in lines
        let fields = split(trim(line), ':')
        if state == 0 
            if fields[0] == 'SF' && fields[1] ==# filename
                let state = 1
            endif
        elseif state == 1
            if fields[0] == 'DA'
                let numbers = split(fields[1], ',')
                let line_no = numbers[0]
                let hits = numbers[1]
                let name = 'vim_lcov_covered'
                if hits == 0
                    let name = 'vim_lcov_not_covered'
                endif
                call sign_place(0, 'vim_lcov', name, bufname('%'), {'lnum': line_no})
            elseif fields[0] == 'SF' && fields[1] !=# filename
                let state = 0
            endif
        endif
    endfor
endfunction

" remove all markers in the current buffer
function! LcovClear() abort
    call sign_unplace('vim_lcov', {'buffer': bufname('%')})
endfunction

function! LcovEnable() abort
    let g:lcov_vim_enable = 1
endfunction

function! LcovDisable() abort
    let g:lcov_vim_enable = 0
endfunction

call sign_define('vim_lcov_covered', {'text': ' ', 'texthl': 'DiffAdd'})
call sign_define('vim_lcov_not_covered', {'text': ' ', 'texthl': 'DiffDelete'})

command! -nargs=0 LcovLoad call LcovLoad()
command! -nargs=0 LcovClear call LcovClear()
command! -nargs=0 LcovEnable call LcovEnable()
command! -nargs=0 LcovDisable call LcovDisable()
