" vim:foldmethod=marker:textwidth=90

if exists('g:vdePluginLoaded')
  finish
endif
let g:vdePluginLoaded = 1

" SECTION: Global Variables: {{{

" Variable: g:vde_projectFile {{{
" Set the default projects description file. In order to set a custom project definition
" file, set the corresponding value in .vimrc
call DetectOption("g:vde_projectFile", expand("$HOME")."/.vim_projects")
"if !exists("g:vde_projectFile")
"    let g:vde_projectFile = expand("$HOME")."/.vim_projects"
"endif "}}}

" Variable: g:vde_projectIndex {{{
" Set the default file that contains a list of project files. In order to set a custom
" project index file, set the corresponding value in .vimrc
call DetectOption("g:vde_projectIndex", "vde.index")
call DetectOption("g:vde_projectTags", "vde.tags")
"if !exists("g:vde_projectIndex")
"    let g:vde_projectIndex = "tags.files"
"endif "}}}

" Variable: g:vde_projectIgnoreList {{{
if !exists("g:vde_projectIgnoreList")
    let g:vde_projectIgnoreList = [ "*.class", "*.dll", "*.so", "*~" ]
    let g:vde_projectIgnoreList += [ "*.a", "*.o" , "*.exe", "*.bin" ]
    let g:vde_projectIgnoreList += [ "*.png", "*.jpg" ]
    let g:vde_projectIgnoreList += [ "ncscope*", "cscope*", "tags" , g:vde_projectTags, g:vde_projectIndex ]
endif "}}}

" Variable: g:vde_projectSkipDirList {{{
call DetectOption("g:vde_projectSkipDirList", [ ".git", ".svn" ])
"if !exists("g:vde_projectSkipDirList")
"    let g:vde_projectSkipDirList = [ ".git", ".svn" ]
"endif "}}}

" Variable: g:OS {{{
" If g:OS is not defined in .vimrc, then do it on our own
if !exists("g:OS")
    if has("unix")
        let g:OS = substitute(system('uname'), "\n", "", "")
    else
        let g:OS = "win"
    endif
endif "}}}

" Variable: g:vde_findCmd {{{
if !exists("g:vde_findCmd")
    if has("unix")
        let g:vde_findCmd = "find"
    else
        let g:vde_findCmd = "find.exe"
    endif
endif "}}}

" Variable: g:vde_ctagsCmd {{{
" If ctags binary has not been redefined, then detect which is a proper one to use
if !exists("g:vde_ctagsCmd")
    if has("unix")
        if g:OS == "FreeBSD"
            let g:vde_ctagsCmd = "exctags"
        else
            let g:vde_ctagsCmd = "ctags"
        endif
    elseif
        let g:vde_ctagsCmd = "ctags.exe"
    endif
endif "}}}

" Variable: g:vde_useGtags {{{
call DetectOption("g:vde_useGtags", 0)
"if !exists("g:vde_useGtags")
"    let g:vde_useGtags = 0
"endif "}}}

" SECTION: if use gtags {{{
if g:vde_useGtags == 1
    " Variable: g:vde_gtagsCmd {{{
    " If gtags binary has not been redefined, then detect which is a proper one to use
    if !exists("g:vde_gtagsCmd")
        if has("unix")
            let g:vde_gtagsCmd = "gtags"
        elseif
            let g:vde_gtagsCmd = "gtags.exe"
        endif
    endif "}}}
endif "}}}

" Variable: g:vde_cscopeCmd {{{
" set cscope binary name
if !exists("g:vde_cscopeCmd")
    if has("unix")
        let g:vde_cscopeCmd = "cscope"
    else
        let g:vde_cscopeCmd = "cscope.exe"
    endif
endif "}}}

" Variable: g:vde_gitCmd {{{
" set git binary name
if !exists("g:vde_gitCmd")
    if has("unix")
        let g:vde_gitCmd = "git"
    else
        let g:vde_gitCmd = "git.exe"
    endif
endif "}}}

" Variable: g:vde_svnCmd {{{
" set svn binary name
if !exists("g:vde_svnCmd")
    if has("unix")
        let g:vde_svnCmd = "svn"
    else
        let g:vde_svnCmd = "svn.exe"
    endif
endif "}}}
"}}}

" SECTION: Local Variables: {{{
" Variable: s:projects {{{
let s:projects = {}
"}}}
"}}}

" CONSTANTS: {{{
let s:PATH = "Path"
let s:VCS = "VCS"
let s:IGNORE = "Ignore"
let s:SKIPDIR = "SkipDir"
let s:USES = "Uses"
let s:GIT = "git"
let s:SVN = "svn"
let s:P4 = "p4"
"let s:TAGSDIR = "TagsDir"
"}}}

" COMMANDS: {{{
"command! -bang -nargs=? VDEInit call s:InitProject(expand("<bang>"))
command! -bang -nargs=? VDEInit call s:InitProject(expand("<bang>"), '<f-args>')
" Version control commands
command! Blame call s:VCSBlame()
command! Diff call VCSDiff(expand("%:p"), "", "")
command! Revisions call s:VCSRevisions()
command! LoadSystemCtags call s:LoadSystemCtags()
"}}}

" FUNCTIONS: {{{

" Function: s:ReadProjects [PRIVATE] {{{
"
" Reads projects description and parameters
"
function s:ReadProjects()
    let s:projects = {}

    if getftype(g:vde_projectFile) == ""
        call Warn("Projects file doesn't exist")
"        execute system("/usr/bin/touch ".g:vde_projectFile)
    endif

    let l:projName = ""

    " read projects file
    for l:sLine in readfile(g:vde_projectFile)
        if l:sLine !~ '^\s*$' && l:sLine !~ '^\s*\#.*$'

            " If we found project name
            if l:sLine =~ '^\s*\[.\+\]\s*$'
                " take value between brackets
                let l:openBrackets = stridx(l:sLine, "[")
                let l:closeBrackets = stridx(l:sLine, "]")
                let l:projName = strpart(l:sLine, l:openBrackets + 1, l:closeBrackets - l:openBrackets - 1)
                let s:projects[l:projName] = {}
            elseif l:sLine =~ '^.\+=.\+$'
                let l:equalPos = stridx(l:sLine, '=')
                let l:param = strpart(l:sLine, 0, l:equalPos)
                let l:value = strpart(l:sLine, l:equalPos + 1)

                let s:projects[l:projName][l:param] = l:value
            endif
        endif
    endfor
endfunction "}}}

" Function: s:InitProject(bang) [PRIVATE] {{{
"
" Arg: bang - expanded <bang> attribute of a command that calls this function. It may be
"             either "!" or an empty string. When expanded to "!" we know that we have to
"             do a full reinit of our project
"
"function! s:InitProject(bang)
function! s:InitProject(bang, desiredProjectName)
    let l:full = 0
    if a:bang == "!"
        let l:full = 1
    endif

    " If we are just regenerating tags, then we need to pick the params of
    " the previously registered project. Otherwise, a new project may be
    " created is VDEInit is run under a subdirectory of project's root
    let l:projectPath = GetProjectParamByFile(expand("%:p:h"), s:PATH)
    if l:projectPath == ""
        let l:projectPath = expand("%:p:h")
    endif

    if a:desiredProjectName == ""
        let l:projectName = s:GetProjectForFile(expand("%:p:h"))
        if l:projectName == ""
"        if l:full == 1 && a:desiredProjectName != ""
"            let l:projectName = a:desiredProjectName
"        else
"            Info("Using autodetected project name.")
            let l:projectName = expand("%:p:h:t")
"        endif
        endif
    else
        let l:projectName = a:desiredProjectName
        " if we happen to override the project name, then remove old record
        let l:oldProjectName = s:GetProjectForFile(expand("%:p:h"))
        if l:oldProjectName != ""
            call remove(s:projects, l:oldProjectName)
        endif
    endif


    " if not registered yet
    if !has_key(s:projects, l:projectName)
        let l:full = 1
        " create a dict for it
        let s:projects[l:projectName] = {}
        " set default values
        let s:projects[l:projectName][s:PATH] = l:projectPath
        let s:projects[l:projectName][s:IGNORE] = join(g:vde_projectIgnoreList, ",")
        let s:projects[l:projectName][s:SKIPDIR] = join(g:vde_projectSkipDirList, ",")
        let s:projects[l:projectName][s:VCS] = DetectVCS(l:projectPath)
    else
        call Warn("Project '".l:projectName."' already exists!")
    endif

    " write project file
    let l:lines = []
    for l:proj in keys(s:projects)
        let l:lines += ["[".l:proj."]"]

        for l:param in keys(s:projects[l:proj])
            let l:lines += [l:param."=".s:projects[l:proj][l:param]]
        endfor
        let l:lines += [""]
    endfor

    call writefile(l:lines, g:vde_projectFile)

"    if l:full == 1
        call s:BuildProjectIndex(l:projectName)
        call s:CscopeSetup(l:projectName)
"    endif
"    call ReadProjects()
    call ReTag("all")
endfunction "}}}

" Function: s:RemoveStaleProjects() [PRIVATE] {{{
"
function s:RemoveStaleProjects()
    for l:key in keys(s:projects)
        if getftype(s:projects[l:key][s:PATH]) != "dir"
            call remove(s:projects, l:key)
        endif
    endfor
endfunction "}}}

" Function: s:GetProjectForFile(filePath) [PRIVATE] {{{
"
""" Returns a name of the project containing the specified file
"
function! s:GetProjectForFile(filePath)
    if a:filePath != ""
        for l:key in keys(s:projects)
            if stridx(a:filePath, s:projects[l:key][s:PATH]) == 0
                return l:key
            endif
        endfor
    endif

    return ""
endfunction "}}}

" Function: s:GetProjectParam [PRIVATE] {{{
"
" Arg: projName - Name of the project
" Arg: paramName - Parameter name
"
" Returns: Parameter value
"
function! s:GetProjectParam(projName, paramName)
    if a:projName != "" && a:paramName != ""
        try
            if has_key(s:projects[a:projName], a:paramName)
                return s:projects[a:projName][a:paramName]
            else
                warn("No ".a:paramName." defined for project '".a:projName."'!"")
            endif
        catch /E716:/
            call Error("No such project '".a:projName."'!")
        catch
            call Error("Unexpected error!")
"            finally
"                return 
        endtry
    endif

    return ""
endfunction "}}}

" Function: GetProjectParamByFile(filePath, paramName) {{{
"
" Arg: filePath - Path to the currently active file
" Arg: paramName - Name of the parameter we are looking for, i.e. Path, VCS, etc
"
function! GetProjectParamByFile(filePath, paramName)
    return s:GetProjectParam(s:GetProjectForFile(a:filePath), a:paramName)
endfunction "}}}

" Function: DetectVCS(path) [PRIVATE] {{{
"
" Detect the vcs for the current file
"
" Arg: path -
"
function! DetectVCS(path)
    let l:usedVCS = ""

    if a:path != ""
        " try svn
        if l:usedVCS == ""
            call system(g:vde_svnCmd." info ".a:path." > /dev/null")
            if v:shell_error == 0
                let l:usedVCS = s:SVN
            endif
        endif

        " try git
        if l:usedVCS == ""
            call system(g:vde_gitCmd." status ".a:path." > /dev/null")
            if v:shell_error == 0
                let l:usedVCS = s:GIT
            endif
        endif

        " try p4
        if l:usedVCS == ""
            let l:oldPwd = getcwd()
            chdir a:path
            call system(g:vde_p4Cmd." info ".a:path." > /dev/null")
            if v:shell_error == 0
                let l:usedVCS = s:P4
            endif
            chdir l:oldPwd
        endif
    endif

    return l:usedVCS
endfunction "}}}

" Function: s:VCSRevisions() [PRIVATE] {{{
"
" Shows revisions for the current file
"
function! s:VCSRevisions()
    let l:currentFile = expand("%:p")
    let l:usedVCS = GetProjectParamByFile(l:currentFile, s:VCS)
    botright new
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    call setline(1, "File: ".l:currentFile)
    call setline(2, "")

    if l:usedVCS == s:GIT
        execute "$read !".g:vde_gitCmd." log --reverse --format='\\%H \\%ai \\%ci \\%s' ".l:currentFile." | sed -e 's/^/    /g'"
    elseif l:usedVCS == s:SVN
        execute "$read !".g:vde_svnCmd." log ".l:currentFile." | egrep \"\\| [0-9]+ line\" | sed -e 's/^/    /g'"
    else
    endif

    map <buffer> 1 :setlocal modifiable<CR>:let linenr=line(".")<CR>:%s/^\[L\]/   /eg<CR>:execute ":".linenr<CR>:s/^   /[L]/<CR>:setlocal nomodifiable<CR>:noh<CR>
    map <buffer> 2 :setlocal modifiable<CR>:let linenr=line(".")<CR>:%s/^\[R\]/   /eg<CR>:execute ":".linenr<CR>:s/^   /[R]/<CR>:setlocal nomodifiable<CR>:noh<CR>
    silent call matchadd('YellowBg', "^\\[L\\].*$")
    silent call matchadd('RedBg', "^\\[R\\].*$")
    map <buffer> <CR> :call VCSDiff(get(split(getline(search("^File:")), '\s\+'), 1), get(split(getline(search("^\\[L\\]")), '\W\+'), 1), get(split(getline(search("^\\[R\\]")), '\W\+'), 1))<CR>
    setlocal nomodifiable
endfunction "}}}

" Function: VCSDiff(file, left, right) [PRIVATE] {{{
"
" Run diff for the file
"
" Arg: file
" Arg: left
" Arg: right
"
function! VCSDiff(file, left, right)
    let l:usedVCS = GetProjectParamByFile(a:file, s:VCS)
    if l:usedVCS == s:GIT
        execute ":!".g:vde_gitCmd." difftool --tool=vimdiff -U0 ".a:left." ".a:right." ".a:file
    elseif l:usedVCS == s:SVN
    else
        call Warn("Warning: No or unsupported VCS!")
    endif
endfunction "}}}

" Function: s:VCSBlame() [PRIVATE] {{{
"
" Run blame for the file
"
function! s:VCSBlame()
    let l:usedVCS = GetProjectParamByFile(expand("%:p"), s:VCS)
    if l:usedVCS == s:GIT
        execute ":!".g:vde_gitCmd." gui blame --line=".line('.')." ".expand("%:p")
    elseif l:usedVCS == s:SVN
        execute ":!".g:vde_svnCmd." annotate ".expand("%:p")
    else
        call Warn("Warning: No or unsupported VCS!")
    endif
endfunction "}}}

" Function: s:VCSCurrentBranch [PRIVATE] {{{
"
" Get current branch name
function! s:VCSCurrentBranch()
    let l:usedVCS = GetProjectParamByFile(expand("%:p"), s:VCS)
    let branch = ""
    if l:usedVCS == s:GIT
        let cmd = g:vde_gitCmd." status | grep branch | head -n1 | cut -d ' ' -f 4"
        let branch = substitute(system(cmd), '\n', '', 'g')
    endif
    return branch
endfunction "}}}

" Function: s:VCSHasLocalChanges() [PRIVATE] {{{
"
" Check whether there are local changes (uncommited)
"
function! s:VCSHasLocalChanges()
    let l:usedVCS = GetProjectParamByFile(expand("%:p"), s:VCS)
    let modified = 0
    if l:usedVCS == s:GIT
        let cmd = g:vde_gitCmd." status | grep modified"
        call system(cmd)
        let modified = !v:shell_error
    endif
    return modified
endfunction "}}}


" Function: s:BuildProjectIndex [PRIVATE] {{{
"
" Arg: projectName - Name of a project
"
function! s:BuildProjectIndex(projectName)
    if !has_key(s:projects, a:projectName)
        return
    endif

    let l:projectPath = s:GetProjectParam(a:projectName, s:PATH)

    " if there is an ignore list, then build a ignore param
    let l:ignore_opt = ""
    if has_key(s:projects[a:projectName], s:IGNORE)
        let l:ignoreList = split(s:projects[a:projectName][s:IGNORE], ",")

        for l:mask in l:ignoreList
"            let l:ignore_opt = l:ignore_opt." ! -path '".l:mask."' "
            let l:ignore_opt = l:ignore_opt." ! -name '".l:mask."' "
        endfor
    endif

    if has_key(s:projects[a:projectName], s:SKIPDIR)
        let l:ignoreList = split(s:projects[a:projectName][s:SKIPDIR], ",")

        for l:mask in l:ignoreList
            let l:ignore_opt = l:ignore_opt." ! -path '*/".l:mask."/*' "
        endfor
    endif

"    if getftype(g:vde_projectIndex) == ""
        "execute g:vde_findCmd." ".l:projectPath." -type f | sed -e 's/[() $]/\\\\\\0/g' > ".l:projectPath."/".g:vde_projectIndex
        "let l:cmd = g:vde_findCmd." ".l:projectPath." -type f ".l:ignore_opt." | sed -e 's/".escape(l:projectPath, "/")."/./g' | sed -e 's/^.*$/\\\"\\0\\\"/g' > ".l:projectPath."/".g:vde_projectIndex
        let l:cmd = g:vde_findCmd." ".l:projectPath." -follow -type f ".l:ignore_opt." | sed -e 's/".escape(l:projectPath, "/")."/./g' | sed -e 's/[() $]/\\\\\\0/g' > ".l:projectPath."/".g:vde_projectIndex
        call system(l:cmd)
"    endif

endfunction "}}}

" Function: s:CscopeSetup(projectName) [PRIVATE] {{{
"
" Arg: projectName
"
function! s:CscopeSetup(projectName)
    let l:projectPath = s:GetProjectParam(a:projectName, s:PATH)
    if l:projectPath != ""
        let l:usedShell = expand("$SHELL")

        execute '!'.g:vde_cscopeCmd.' -q -b -i '.g:vde_projectIndex
        " if [t]csh
        if stridx(l:usedShell, 'csh') >= 0
            execute ':!setenv CSCOPE_DB '.l:projectPath.'/cscope.out'
        else
            execute ':!export CSCOPE_DB='.l:projectPath.'/cscope.out'
        endif
    endif

    return
endfunction "}}}

" Function ReTag(code) [PRIVATE] {{{
" Rebuild tags and save them to the project's top dir
"
" Arg: code - operation code
"           "load" - find tags file and set it
"           "single-file" - update tags for the current file
"           "all" - full rebuild of ctags
"
function! ReTag(code)
    if a:code == ""
        return
    endif

    let l:projectName = s:GetProjectForFile(expand("%:p"))
    let l:projectPath = s:GetProjectParam(l:projectName, s:PATH)

    if l:projectPath != ""
        if a:code == "single-file"
            " retag the file to l:projectPath/g:vde_projectTags
            if g:vde_useGtags == 1
                execute "silent! :!".g:vde_gtagsCmd." --single-update ".expand("%")
            endif

            execute "silent! :!".g:vde_ctagsCmd." -R -a --sort=no --c++-kinds=+p --fields=+iaS --extra=+q -f ".l:projectPath."/".g:vde_projectTags." ".expand("%:p")
        elseif a:code == "load"
            let l:paths = []
            call add(l:paths, l:projectPath."/".g:vde_projectTags)

            let l:uses = split(s:GetProjectParam(l:projectName, s:USES), ',')

"            let l:paths += map(l:uses, 's:GetProjectParam(v:val, s:PATH)')

            for l:dep in l:uses
                " if a dependency is a project name
                if has_key(s:projects, l:dep)
                    call add(l:paths, s:GetProjectParam(l:dep, s:PATH)."/".g:vde_projectTags)
                " else if a dependency is a path to tags file
                elseif getftype(expand(l:dep)) == "file"
                    call add(l:paths, expand(l:dep))
                elseif getftype(expand(l:dep)) == "dir"
                    call Error("A dir is specified as a dependency. Don't know what to do with it!")
                " else we don't know what to do with this dependency
                else
                    call Warn("No such dependency: ".l:dep)
                endif
            endfor

"            " check and add tags for projects listed in Uses param
            for l:dep in l:paths
                " if the tags hasn't been added yet
"                if stridx(&tags, l:dep) == -1
                    execute "silent! setlocal tags+=".l:dep
"                endif
            endfor

        elseif a:code == "all"
            if g:vde_useGtags == 1
                execute ":!".g:vde_gtagsCmd." -f ".l:projectPath."/".g:vde_projectIndex." -I ."
            endif
            execute ":!".g:vde_ctagsCmd." -f ".l:projectPath."/".g:vde_projectTags." -L ".l:projectPath."/".g:vde_projectIndex." -V --c++-kinds=+p --fields=+iaS --extra=+q"
            " \todo Maybe retag deps ?
        endif
"        silent call s:CscopeSetup()
    endif
endfunction "}}}

" Function s:LoadSystemCtags [PRIVATE] {{{
" Reads ctags generated files from ~/.vim/dev_tags and offers to load the one you choose.
function! s:LoadSystemCtags()
    let l:vimdir = get(split(&rtp, ','), 0)."/dev_tags"

    let l:tagFiles = split(system("find ".l:vimdir." -type f | xargs -l basename"), '\n')

    let l:i = 0
    echo "Choose tags file: "
"    for f in map(l:tagFiles, 'v:key.": ".v:val')
    for f in l:tagFiles
        echo l:i.": ".f
        let l:i = l:i + 1
    endfor

    let l:id = input("Your choice: ")
    echo l:id
    if l:id < len(l:tagFiles) && l:id >= 0
        execute ":set tags=".l:vimdir."/".l:tagFiles[l:id].",".&tags
    end
endfunction "}}}
"}}}

" Function: VDEGrepProjectFiles()
" Searches for specified patterns in project files, excluding binary files.
function! VDEGrepProjectFiles(pattern, caseSensitive)
    let root = GetProjectParamByFile(expand('%:p'), 'Path')
    if root == ""
        let root = getcwd()
    end

    if a:caseSensitive == 1
        let grepFlags = ""
    else
        let grepFalgs = "-i"
    endif

    let xargsFlags = ""
    if g:OS != "FreeBSD"
        let xargsFlags = "-l"
    endif

    let cmd = "cat ".root."/".g:vde_projectIndex." | xargs ".xargsFlags." grep ".grepFlags." -HIn \"".a:pattern."\""
    let cmd .= " | sed -e 's#^".root."##g'"

    call ExecSearch(cmd, "", "")
endfunction

function! VDEOnBufEnter()
"    let b:repoInfo = { 'branch': s:VCSCurrentBranch(), 'modified': s:VCSHasLocalChanges() }
endfunction

function! VDEOnCursorHold()
    let symbol = expand("<cword>")
"    if symbol == ""
"        finish
"    endif
endfunction

" Function: VDERepoInfoStr() {{{
function! VDERepoInfoStr()
    let s = " [Project: ".s:GetProjectForFile(expand("%:p"))
    if exists("b:repoInfo") 
        if has_key(b:repoInfo, 'branch') &&  b:repoInfo.branch != ''
            let s .= ' ('
            let s .= b:repoInfo.branch
            if has_key(b:repoInfo, 'modified') && b:repoInfo.modified == 1
                let s .= '*'
            endif
            let s .= ')'
        endif
    endif
    let s .= "]"
    return s
endfunction "}}}


" Function: Info(msg) [Helper func] {{{
" Displays info message
"
" param[in] msg - Message to show
"
function! Info(msg)
    echomsg "[VDE] ".a:msg
endfunction "}}}

" Function: Warn(msg) [Helper func] {{{
" Displays warning message
"
" param[in] msg - Message to show
"
function! Warn(msg)
    echohl WarningMsg | echomsg "[VDE] ".a:msg | echohl None
endfunction "}}}

" Function: Error(msg) [Helper func] {{{
" Displays error message
"
" param[in] msg - Message to show
"
function! Error(msg)
    echohl ErrorMsg | echomsg "[VDE] ".a:msg | echohl None
endfunction "}}}
"}}}

" SECTION: UnitTest helpers {{{
function! s:get_SID()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! vde#__context__()
    return { 'sid': s:SID, 'scope': s: }
endfunction
"}}}

"}}}
" SECTION: Initialization: {{{
" Read to project
call s:ReadProjects()
"}}}

" AUTOCOMMANDS: {{{
if has("autocmd")
    augroup CtagsGrp
        au!
        au BufWritePost * if &modifiable | silent call ReTag("single-file") | redraw!
        "au BufNew * if &modifiable | silent call ReTag("load") | redraw!
        au BufEnter * if &modifiable | call VDEOnBufEnter()
        au CursorHold * if &modifiable | call VDEOnCursorHold()
"        au BufEnter * if &modifiable | silent call VDEOnBufEnter()
        au BufEnter * if &modifiable | silent call ReTag("load") | redraw!
    augroup END
endif " has("autocmd")
"}}}

