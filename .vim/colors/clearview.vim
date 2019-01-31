" Vim color file
" Maintainer:   Your name <youremail@something.com>
" Last Change:
" URL:

" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

" your pick:
set background=dark " or light
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="clearview"

"hi Normal

" OR

" highlight clear Normal
" set background&
" highlight clear
" if &background == "light"
"   highlight Error ...
"   ...
" else
"   highlight Error ...
"   ...
" endif

" A good way to see what your colorscheme does is to follow this procedure:
" :w
" :so %
"
" Then to see what the current setting is use the highlight command.
" For example,
" 	:hi Cursor
" gives
"	Cursor         xxx guifg=bg guibg=fg

" Uncomment and complete the commands you want to change from the default.

hi   LineNr       cterm=none ctermfg=240     ctermbg=none

hi   Comment      cterm=none ctermfg=246      ctermbg=none
hi   Constant     cterm=none ctermfg=167     ctermbg=none
hi   Identifier   cterm=none ctermfg=67      ctermbg=none
hi   Function     cterm=none ctermfg=136     ctermbg=none

hi   Statement    cterm=none ctermfg=179     ctermbg=none

hi   String       cterm=none ctermfg=107     ctermbg=none
hi   PreProc      cterm=none ctermfg=81      ctermbg=none
hi   Type         cterm=none ctermfg=156     ctermbg=none
hi   Special      cterm=none ctermfg=73      ctermbg=none

hi   FoldColumn   cterm=none ctermfg=cyan    ctermbg=none
hi   Folded       cterm=none ctermfg=white   ctermbg=none

hi   SpellBad     cterm=none ctermfg=202     ctermbg=237

hi Pmenu cterm=none ctermfg=white ctermbg=238
hi Search cterm=none ctermfg=none ctermbg=237

hi CursorLine cterm=none ctermbg=233

hi WildMenu ctermfg=cyan ctermbg=black
verbose hi StatusLine ctermfg=black ctermbg=black
hi StatusLineNC ctermfg=black ctermbg=blue

hi DiffAdd ctermfg=lightgray ctermbg=darkgrey
hi DiffDelete ctermfg=darkred ctermbg=black
hi DiffChange ctermfg=lightgray ctermbg=68
hi DiffText ctermfg=white ctermbg=68

" Sign column change for gitgutter
hi SignColumn ctermbg=none

set fcs+=vert:│
hi VertSplit ctermbg=none cterm=none ctermfg=152

" Use folds, but leave them open initially
set foldlevelstart=20
set foldlevel=20

"fun tempColors()
"    let num = 255
"    while num >= 0
"        exec 'hi col_'.num.' ctermbg='.num.' ctermfg=white'
"        exec 'syn match col_'.num.' "ctermbg='.num.':...." containedIn=ALL'
"        call append(0, 'ctermbg='.num.':....')
"        let num = num - 1
"    endwhile
"endfun
"hi Cursor
"hi CursorIM
"hi Directory
"hi DiffAdd
"hi DiffChange
"hi DiffDelete
"hi DiffText
"hi ErrorMsg
"hi VertSplit
"hi Folded
"hi FoldColumn
"hi IncSearch
"hi LineNr
"hi ModeMsg
"hi MoreMsg
"hi NonText
"hi Question
"hi Search
"hi SpecialKey
"hi StatusLine
"hi StatusLineNC
"hi Title
"hi Visual
"hi VisualNOS
"hi WarningMsg
"hi WildMenu
"hi Menu
"hi Scrollbar
"hi Tooltip

" syntax highlighting groups
"hi Comment
"hi Constant
"hi Identifier
"hi Statement
"hi PreProc
"hi Type
"hi Special
"hi Underlined
"hi Ignore
"hi Error
"hi Todo

