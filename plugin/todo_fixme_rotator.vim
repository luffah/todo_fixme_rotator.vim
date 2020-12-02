" todo_fixme_rotator.vim -- Vim tool for fast add/change on TODO / FIXME items
" @Author:      luffah (luffah AT runbox com)
" @License:     AGPLv3 (see https://www.gnu.org/licenses/agpl-3.0.txt)
" @Created:     2020-12-02
" @Last Change: 2020-12-02
" @Revision:    1
"
" @AsciiArt
"  ┌─────┐ ┌───┐   ┌─┐ ┌───┐ 
"  └──┐ ┌┘ │   │ ┌─┘ │ │   │ 
"     │ │  │   │ │   │ │   │ 
"     └─┘  └───┘ └───┘ └───┘
"     TODO DONE  PENDING
"     FIXME             ROTATOR
"
" @global g:todo_fixme_rotator_todo_values
" values to set as TODO in left to right order
" default : ['TODO', 'DONE', 'PENDING', '']
let s:todo_values = get(g:,'todo_fixme_rotator_todo_values',
      \ ['TODO', 'DONE', 'PENDING', ''])

" @global g:todo_fixme_rotator_fixme_values
" values to set as FIXME in left to right order
" default : ['FIXME', '']
let s:fixme_values =  get(g:, 'todo_fixme_rotator_fixme_values',
      \ ['FIXME', ''])

let s:markdown_like_ft = ['markdone', 'org', 'zim', 'rst']
let s:bash_like_ft = ['python', 'bash']
let s:java_like_ft = ['java', 'javascript', 'cpp', 'c']
let s:vim_like_ft = ['vim', 'ruby']

function! s:inlineInsertUpdateTODO(li, fixmode)
    let l:l=getline(a:li)
    let l:idx=-1
    let l:pattern=""
    if a:fixmode
      let l:todo_values = s:fixme_values
    else
      let l:todo_values = s:todo_values
    endif
    for l:i in range(len(l:todo_values))
      if !len(l:todo_values[l:i])
        continue
      endif
      let l:pattern = '\(\W\|^\)\('.l:todo_values[l:i].'\)\(\W\|$\)'
      if l:l =~ l:pattern
        let l:idx=l:i
        break
      endif
    endfor
    if l:idx==-1
      if ( index(s:markdown_like_ft, &ft) > -1 ) 
        if l:l =~ '^\s*[=#]\+\s'
          let l:l=substitute(l:l, '^\(\s*[=#]\+\s\)\(.*\)$',
                \ '\1'.l:todo_values[0].' \2', '')
        else  " these languages have no comments
          let l:l = l:l.' '.l:todo_values[0]
        endif
      elseif ( index(s:vim_like_ft, &ft) > -1 ) && l:l =~ '^\s*["]\+\s'
        let l:l=substitute(l:l, '^\(\s*["]\+\s\)\(.*\)$',
              \ '\1'.l:todo_values[0].' \2', '')
      elseif ( index(s:java_like_ft, &ft) > -1 ) && l:l =~ '^\s*/[/*]\+\s'
        let l:l=substitute(l:l, '^\(\s*/[/*]\+\s\)\(.*\)$',
              \ '\1'.l:todo_values[0].' \2', '')
      else
        if synIDattr(synID(a:li, strlen(l:l), 1),'name')=~?'comment'
          let l:l = l:l.' '.l:todo_values[0]
        else
          let l:l = l:l.' '.printf(&commentstring, l:todo_values[0])
        endif
      endif
    else
      " rotate
      let l:nextidx=(l:idx+1)%len(l:todo_values)
      let l:val=l:todo_values[l:nextidx]
      if !len(l:val)
        let l:newpattern = '\(\W\|^\)\( '.l:todo_values[l:idx].'\)\(\W\|$\)'
        if l:l !~ l:newpattern
          let l:newpattern = '\(\W\|^\)\('.l:todo_values[l:idx].' \)\(\W\|$\)'
        endif
        if l:l =~ l:newpattern
          let l:pattern=l:newpattern
        endif
      endif
      let l:l = substitute(l:l, l:pattern, '\1'.l:val.'\3','g')
    endif

    call setline(a:li, l:l)
endfunction

" @mapping <leader>T
" add/update TODO
map <leader>T :call <SID>inlineInsertUpdateTODO(line('.'),0)<cr>

" @mapping <leader>F
" add/update FIXME
map <leader>F :call <SID>inlineInsertUpdateTODO(line('.'),1)<cr>
