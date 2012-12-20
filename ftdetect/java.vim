
" Java files that will be processed by a preprocessor
au BufNewFile,BufRead *.jpp setfiletype java
au Filetype java setlocal omnifunc=javacomplete#Complete
