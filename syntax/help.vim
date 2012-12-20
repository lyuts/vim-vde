"hi Tag ctermfg=134

"map <F11> :execute ":sp ".expand("%:h")."/tags"<CR>:%s/^\([^     :]*:\)\=\([^    ]*\).*/syntax keyword Tag \2/<CR>:execute ":wq! ".expand("%:h")."/tags.vim"<CR>/^<CR><F12>
"map <F12> :execute ":so ".expand("%:h")."/tags.vim"<CR>:nohl<CR>
