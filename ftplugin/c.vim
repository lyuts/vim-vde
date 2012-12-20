
if !exists("saved_default_alternateSearchPath")
    let saved_default_alternateSearchPath = 1

    let g:defaultAlternateSearchPath = g:alternateSearchPath
endif

let g:alternateSearchPath = g:defaultAlternateSearchPath

" get top dir
let s:path = GetProjectParamByFile(expand("%:p"), "Path")

if s:path != ""
"    let s:path = getcwd()

    let s:fname = strpart(expand("%:t"), 0, stridx(expand("%:t"), '.'))

    let s:dirs = system("find ".s:path." -type f -iname '".s:fname."*' | xargs -l dirname | sort -u ")
    let s:dirlist = split(s:dirs, "\n")

    for dir in s:dirlist
        if stridx(g:alternateSearchPath, dir) == -1
            let g:alternateSearchPath = g:alternateSearchPath.",abs:".dir
        endif
    endfor
endif

