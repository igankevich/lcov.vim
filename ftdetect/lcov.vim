autocmd BufRead * if exists('g:lcov_vim_enable') && g:lcov_vim_enable == 1 | call LcovLoad() | endif
