
"if has("syntax") && !exists("did_c_syntax_init")
    let did_c_syntax_init = 1

    """""""""
    """ Types
    """""""""
"    syn keyword QtType qint8 qint16 qint32 qint64

    """""""""""""
    """ Functions
    """""""""""""
    syn match myParenthesis "[()]"
"    syn match myParenthesis "{" contains=myParenthesis
"    syn match myParenthesis "}" contains=myParenthesis
    syn match myParenthesis "\["
    syn match myParenthesis "\]"


"    syn match myColon ":"
"    syn match mySemiColon ";"

    syn match myOperators "+"
    syn match myOperators "-"
    syn match myOperators "*"
    syn match myOperators "/"
    syn match myOperators "|"
    syn match myOperators "&"
    syn match myOperators "="
    syn match myOperators "!="
    syn match myOperators ">"
    syn match myOperators ">="
    syn match myOperators "<"
    syn match myOperators "<="
    syn match myOperators "%"

    " highlight constants
"    syn match myConstant "_\?\([A-Z0-9_]\+_\)\+[A-Z0-9]\+_\?"
    "syn match myConstant "[^a-z][A-Z0-9_]\+[^a-z]"

    command! -nargs=+ HighlightWord hi link <args>

    hi myParenthesis ctermfg=blue guifg=blue

"    HighlightWord myCurlyBraces clear
"    HighlightWord myColon clear
"    HighlightWord mySemiColon clear

    HighlightWord myOperators Special
    HighlightWord myConstant Constant

    execute ":source ".expand("<sfile>:h")."/doxygen.vim"
"endif

