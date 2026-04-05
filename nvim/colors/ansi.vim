" https://hamvocke.com/blog/ansi-vim-color-scheme/
" Supports both dark and light backgrounds via terminal ANSI colors.

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'ansi'
set notermguicolors

" This color scheme relies on ANSI colors only. It automatically inherits
" the 16 colors of your terminal color scheme. You can change the colors of
" certain highlight groups by picking a different color from the following set
" of colors. If you sticked to the ANSI color palette conventions when setting
" colors in your terminal emulator, this will look pretty neat. If you used
" a terminal color scheme that uses a different convention (e.g. base16)
" colors will likely look very odd if you use this color scheme.
"
" 0: Black        │   8: Bright Black (dark gray)
" 1: Red          │   9: Bright Red
" 2: Green        │  10: Bright Green
" 3: Yellow       │  11: Bright Yellow
" 4: Blue         │  12: Bright Blue
" 5: Magenta      │  13: Bright Magenta
" 6: Cyan         │  14: Bright Cyan
" 7: White (gray) │  15: Bright White
"
" Use the 'cterm' argument to make certain highlight groups appear in italic
" (if your terminal and font support it), bold, reverse, underlined, etc.
" See ':help attr-list' for possible options.

" Editor Elements — background-adaptive
" Uses 0/15 (black/white) which swap roles depending on terminal theme.
hi NonText ctermfg=8
hi Ignore ctermfg=NONE  ctermbg=NONE cterm=NONE
hi Underlined cterm=underline
hi Bold cterm=bold
hi Italic cterm=italic
hi Title ctermfg=4 cterm=bold
hi LineNr ctermfg=8
hi CursorLineNr ctermfg=6
hi helpLeadBlank ctermbg=NONE ctermfg=NONE
hi helpNormal ctermbg=NONE ctermfg=NONE
hi FoldColumn ctermfg=7
hi Folded ctermfg=12
hi SpellBad cterm=undercurl
hi SpellCap cterm=undercurl
hi SpellLocal cterm=undercurl
hi SpellRare cterm=undercurl
hi SignColumn ctermfg=7
hi MoreMsg ctermfg=4
hi Question ctermfg=4
hi Conceal ctermfg=8
hi debugPC ctermfg=7
hi debugBreakpoint ctermfg=8
hi ErrorMsg ctermfg=1 cterm=bold,italic
hi WarningMsg ctermfg=11
hi Directory ctermfg=4
hi SpecialKey ctermfg=8
hi IncSearch ctermbg=1 ctermfg=0
hi CurSearch ctermbg=3 ctermfg=0
hi Search ctermbg=11 ctermfg=0
hi MatchParen ctermbg=NONE ctermfg=3 cterm=underline,bold
hi ColorColumn ctermbg=8
hi diffAdded ctermfg=10
hi diffRemoved ctermfg=9
hi diffChanged ctermfg=12
hi diffOldFile ctermfg=11
hi diffNewFile ctermfg=13
hi diffFile ctermfg=12
hi diffLine ctermfg=7
hi diffIndexLine ctermfg=14
hi healthError ctermfg=1
hi healthSuccess ctermfg=2
hi healthWarning ctermfg=3

if &background ==# 'dark'
  hi StatusLine ctermfg=15 ctermbg=8 cterm=NONE
  hi StatusLineNC ctermfg=15 ctermbg=0 cterm=NONE
  hi VertSplit ctermfg=0 ctermbg=NONE
  hi WinSeparator ctermfg=0 ctermbg=NONE
  hi TabLine ctermfg=7 ctermbg=0
  hi TabLineFill ctermfg=0 ctermbg=NONE
  hi TabLineSel ctermfg=0 ctermbg=11
  hi CursorLine ctermbg=0 ctermfg=NONE
  hi Cursor ctermbg=15 ctermfg=0
  hi CursorColumn ctermbg=0
  hi Visual ctermbg=8 ctermfg=15 cterm=bold
  hi VisualNOS ctermbg=8 ctermfg=15 cterm=bold
  hi Pmenu ctermbg=0 ctermfg=15
  hi PmenuSbar ctermbg=8 ctermfg=7
  hi PmenuSel ctermbg=8 ctermfg=15 cterm=bold
  hi PmenuThumb ctermbg=7 ctermfg=NONE
  hi WildMenu ctermbg=0 ctermfg=15 cterm=NONE
  hi QuickFixLine ctermbg=0 ctermfg=14
  hi ModeMsg ctermbg=15 ctermfg=0 cterm=bold
  hi ToolbarLine ctermbg=0 ctermfg=15
  hi ToolbarButton ctermbg=8 ctermfg=15
  hi DiffAdd ctermbg=10 ctermfg=0
  hi DiffChange ctermbg=12 ctermfg=0
  hi DiffDelete ctermbg=9 ctermfg=0
  hi DiffText ctermbg=14 ctermfg=0
else
  hi StatusLine ctermfg=0 ctermbg=7 cterm=NONE
  hi StatusLineNC ctermfg=8 ctermbg=7 cterm=NONE
  hi VertSplit ctermfg=7 ctermbg=NONE
  hi WinSeparator ctermfg=7 ctermbg=NONE
  hi TabLine ctermfg=8 ctermbg=7
  hi TabLineFill ctermfg=7 ctermbg=NONE
  hi TabLineSel ctermfg=15 ctermbg=4
  hi CursorLine ctermbg=7 ctermfg=NONE
  hi Cursor ctermbg=0 ctermfg=15
  hi CursorColumn ctermbg=7
  hi Visual ctermbg=7 ctermfg=0 cterm=bold
  hi VisualNOS ctermbg=7 ctermfg=0 cterm=bold
  hi Pmenu ctermbg=7 ctermfg=0
  hi PmenuSbar ctermbg=7 ctermfg=8
  hi PmenuSel ctermbg=8 ctermfg=15 cterm=bold
  hi PmenuThumb ctermbg=8 ctermfg=NONE
  hi WildMenu ctermbg=7 ctermfg=0 cterm=NONE
  hi QuickFixLine ctermbg=7 ctermfg=4
  hi ModeMsg ctermbg=0 ctermfg=15 cterm=bold
  hi ToolbarLine ctermbg=7 ctermfg=0
  hi ToolbarButton ctermbg=8 ctermfg=15
  hi DiffAdd ctermbg=2 ctermfg=15
  hi DiffChange ctermbg=4 ctermfg=15
  hi DiffDelete ctermbg=1 ctermfg=15
  hi DiffText ctermbg=6 ctermfg=0
endif

" Syntax
hi Comment ctermfg=8 cterm=italic
hi Constant ctermfg=3
hi Error ctermfg=1
hi Identifier ctermfg=9
hi Function ctermfg=4
hi Special ctermfg=13
hi Statement ctermfg=5
hi String ctermfg=2
hi Operator ctermfg=6
hi Boolean ctermfg=3
hi Label ctermfg=14
hi Keyword ctermfg=5
hi Exception ctermfg=5
hi Conditional ctermfg=5
hi PreProc ctermfg=13
hi Include ctermfg=5
hi Macro ctermfg=5
hi StorageClass ctermfg=11
hi Structure ctermfg=11
hi Todo ctermfg=0 ctermbg=9 cterm=bold
hi Type ctermfg=11

" Treesitter highlighting
" - allows for more precise syntax highlighting
" - only available for nvim >0.5
" - see also :help treesitter-highlight-groups

hi @variable ctermfg=15
hi @variable.builtin ctermfg=1
hi @variable.parameter ctermfg=1
hi @variable.member ctermfg=1
hi @constant.builtin ctermfg=5
hi @string.regexp ctermfg=1
hi @string.escape ctermfg=6
hi @string.special.url ctermfg=4 cterm=underline
hi @string.special.symbol ctermfg=13
hi @type.builtin ctermfg=3
hi @property ctermfg=1
hi @function.builtin ctermfg=5
hi @constructor ctermfg=11
hi @keyword.coroutine ctermfg=1
hi @keyword.function ctermfg=5
hi @keyword.return ctermfg=5
hi @keyword.export ctermfg=14
hi @punctuation.bracket ctermfg=15
hi @comment.error ctermbg=9 ctermfg=0
hi @comment.warning ctermbg=11 ctermfg=0
hi @comment.todo ctermbg=12 ctermfg=0
hi @comment.note ctermbg=14 ctermfg=0
hi @markup ctermfg=15
hi @markup.strong ctermfg=15 cterm=bold
hi @markup.italic ctermfg=15 cterm=italic
hi @markup.strikethrough ctermfg=15 cterm=strikethrough
hi @markup.heading ctermfg=4 cterm=bold
hi @markup.quote ctermfg=6
hi @markup.math ctermfg=4
hi @markup.link.url ctermfg=5 cterm=underline
hi @markup.raw ctermfg=14
hi @markup.list.checked ctermfg=2
hi @markup.list.unchecked ctermfg=7
hi @tag ctermfg=5
hi @tag.builtin ctermfg=6
hi @tag.attribute ctermfg=4
hi @tag.delimiter ctermfg=15

hi link @variable.parameter.builtin @variable.parameter
hi link @constant Constant
hi link @constant.macro Macro
hi link @module Structure
hi link @module.builtin Special
hi link @label Label
hi link @string String
hi link @string.special Special
hi link @character Character
hi link @character.special SpecialChar
hi link @boolean Boolean
hi link @number Number
hi link @number.float Float
hi link @type Type
hi link @type.definition Type
hi link @attribute Constant
hi link @attribute.builtin Constant
hi link @function Function
hi link @function.call Function
hi link @function.method Function
hi link @function.method.call Function
hi link @operator Operator
hi link @keyword Keyword
hi link @keyword.operator Operator
hi link @keyword.import Include
hi link @keyword.type Keyword
hi link @keyword.modifier Keyword
hi link @keyword.repeat Repeat
hi link @keyword.debug Exception
hi link @keyword.exception Exception
hi link @keyword.conditional Conditional
hi link @keyword.conditional.ternary Operator
hi link @keyword.directive PreProc
hi link @keyword.directive.define Define
hi link @punctuation.delimiter Delimiter
hi link @punctuation.special Special
hi link @comment Comment
hi link @comment.documentation Comment
hi link @markup.underline underline
hi link @markup.link Tag
hi link @markup.link.label Label
hi link @markup.list Special
hi link @diff.plus diffAdded
hi link @diff.minus diffRemoved
hi link @diff.delta diffChanged

" nvim-tree colors
hi NvimTreeNormal ctermfg=NONE ctermbg=NONE
hi NvimTreeFolderIcon ctermfg=4
hi NvimTreeFolderName ctermfg=4
hi NvimTreeOpenedFolderName ctermfg=4
hi NvimTreeGitDirty ctermfg=3
hi NvimTreeGitStaged ctermfg=2
hi NvimTreeGitDeleted ctermfg=1
hi NvimTreeGitNew ctermfg=6
hi NvimTreeGitIgnored ctermfg=8
hi NvimTreeSpecialFile ctermfg=13 cterm=underline
hi NvimTreeSymlink ctermfg=6 cterm=italic
hi NvimTreeRootFolder ctermfg=11 cterm=bold
