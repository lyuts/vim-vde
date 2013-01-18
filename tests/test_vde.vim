let s:tc = unittest#testcase#new('VDETests', vde#__context__())

" Test suites setup and teardown {{{
function! s:tc.SETUP()
    let s:vdeProjDictName = 's:projects'
    let s:sampleProjectName = 'Project1'

    let s:sampleProjects = {}
    let s:sampleProjects[s:sampleProjectName] = {}
    let s:sampleProjects[s:sampleProjectName][self.get('s:PATH')] = '/path1'
    let s:sampleProjects[s:sampleProjectName][self.get('s:VCS')] = 'git'
    let s:sampleProjects[s:sampleProjectName][self.get('s:IGNORE')] = 'IGNORE'
    let s:sampleProjects[s:sampleProjectName][self.get('s:SKIPDIR')] = 'SKIPDIR'
    let s:sampleProjects[s:sampleProjectName][self.get('s:USES')] = 'USES'
endfunction

function! s:tc.TEARDOWN()
    call self.set(s:vdeProjDictName, {})
endfunction
"}}}

" Tests: Constants {{{
function! s:tc.test_Constants()
    call self.assert_not_equal(0, self.get('g:vdePluginLoaded'))
    call self.assert_equal('Path', self.get('s:PATH'))
    call self.assert_equal('VCS', self.get('s:VCS'))
    call self.assert_equal('Ignore', self.get('s:IGNORE'))
    call self.assert_equal('SkipDir', self.get('s:SKIPDIR'))
    call self.assert_equal('Uses', self.get('s:USES'))
    call self.assert_equal('git', self.get('s:GIT'))
    call self.assert_equal('svn', self.get('s:SVN'))
    call self.assert_equal('p4', self.get('s:P4'))
endfunction
"}}}

" Tests: RemoveStaleProjects {{{
function! s:tc.test_RemoveStaleProjects()
    let sampleProjectsCount = len(s:sampleProjects)
    call self.set(s:vdeProjDictName, deepcopy(s:sampleProjects))
    call self.call('s:RemoveStaleProjects', [])
    call self.assert_equal(0, len(self.get('s:projects')))
    call self.assert_equal(sampleProjectsCount, len(s:sampleProjects))
endfunction
"}}}

" Tests: GetProjectForFile {{{
function! s:tc.test_GetProjectForFile()
    call self.set(s:vdeProjDictName, deepcopy(s:sampleProjects))
    call self.assert_equal(s:sampleProjectName, self.call('s:GetProjectForFile', [ '/path1/main.cpp' ]))
    call self.assert_equal(s:sampleProjectName, self.call('s:GetProjectForFile', [ '/path1/src/main.cpp' ]))
    call self.assert_equal(s:sampleProjectName, self.call('s:GetProjectForFile', [ '/path1/src/' ]))
    call self.assert(empty(self.call('s:GetProjectForFile', [ '/home/user1/src/main.cpp' ])))
endfunction
"}}}

" Tests: GetParamByFile {{{
function! s:tc.test_GetProjectParamByFile()
    call self.set(s:vdeProjDictName, deepcopy(s:sampleProjects))
    let sampleSrcFile = '/path1/src/main.cpp'
    let params = [ 's:PATH', 's:VCS', 's:IGNORE', 's:SKIPDIR', 's:USES' ]
    for param in params
        let actual = self.call('GetProjectParamByFile', [ sampleSrcFile, self.get(param) ])
        let expected = self.get(s:vdeProjDictName)[s:sampleProjectName][self.get(param)]
        call self.assert_equal(expected, actual)
    endfor
endfunction
"}}}

" Test Group: GetProjectParam {{{
function! s:tc.setup_GetProjectParam()
    call self.assert_is_Dictionary(self.get(s:vdeProjDictName))
    call self.set(s:vdeProjDictName, deepcopy(s:sampleProjects))
    call self.assert_not(empty(self.get(s:vdeProjDictName)), 'No test projects defined!')
    call self.assert_has_key(s:sampleProjectName, self.get(s:vdeProjDictName))
endfunction

" Test: Test GetProjectParam. {{{
function! s:tc.test_GetProjectParam()
    let params = [ 's:PATH', 's:VCS', 's:IGNORE', 's:SKIPDIR', 's:USES' ]
    for param in params
        let actual = self.call('s:GetProjectParam', [ s:sampleProjectName, self.get(param) ])
        let expected = self.get(s:vdeProjDictName)[s:sampleProjectName][self.get(param)]
        call self.assert_equal(expected, actual)
    endfor
endfunction
"}}}


"}}}


