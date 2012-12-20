
"if has("syntax") && !exists("did_java_syntax_init")
    let did_java_syntax_init = 1

    syn keyword JavaType byte
    syn keyword JavaType String
    syn keyword JavaType System
    syn keyword JavaType Vector

    command! -nargs=+ HighlightWord hi link <args>

    HighlightWord JavaType Type

    execute ":source ".expand("<sfile>:h")."/cpp.vim"
    execute ":source ".expand("<sfile>:h")."/doxygen.vim"
"endif

