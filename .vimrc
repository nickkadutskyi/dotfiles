" Shared setting betwen Vim, Neovim, Ideavim

" line numbers
set nu
" line numbers are relative
set relativenumber

" Signcolumn
set signcolumn=yes

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Split configs
set splitbelow
set splitright

" Search settings
" set nohlsearch
set hlsearch
set incsearch

set autoindent
set smartindent

" Enables cursor line highlight groups
set cursorline

" Soft wrap
set wrap
set nolinebreak
set nolist

if has('linebreak')
  set breakindent
  let &showbreak = '↳ '
  set breakindentopt=shift:0,min:20,sbr
end

" Hard wrap
" set textwidth=120

let mapleader = " "

set mouse=a

set termguicolors

set scrolloff=3
set isfname+=@-@

" Addes yanked text into system's clipboard
" if has("unnamedplus")
"   set clipboard=unnamedplus
" else
"   set clipboard=unnamed
" endif


" Remap
"
" When deleting string don't add it to the register
nnoremap <leader>d "_d
vnoremap <leader>d "_d
nnoremap <leader>D "_D
vnoremap <leader>D "_D
" When changing string don't add it to the register
nnoremap <leader>c "_c
vnoremap <leader>c "_c
nnoremap <leader>C "_C
vnoremap <leader>C "_C
" :
" When deleting a character don't add it to the register
nnoremap <leader>x "_x
vnoremap <leader>x "_x

" Paste over a selected text in visual mode without overwriting register
xnoremap <leader>p "_dP
" Yank to system clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+Y
" Paste from system clipboard
" nnoremap <leader>p "+p
nnoremap <leader>P "+P
xnoremap <leader>P "+P

" Move cursor down half a page
" nnoremap <C-d> <C-d>zz
" Move cursor half a page down and centers cursor unless it's end of file then scroll 3
" lines past the end of file
nnoremap <expr> <C-d> (line('$') - line('.') - line('w$') + line('w0')) > 0 ? "\<C-d>zz" : "\<C-d>zb<C-e><C-e><C-e>"
" Move cursor up half page and center window
nnoremap <C-u> <C-u>zz
" Go to next search occurance and center window
nnoremap n nzzzv
" Go to previous search occurance and center window
nnoremap N Nzzzv

" Code Editing
"
" Move hightlighted Code
nnoremap <S-Down> :m .+1<CR>==
nnoremap <S-Up> :m .-2<CR>==
inoremap <S-Down> <Esc>:m .+1<CR>==gi
inoremap <S-Up> <Esc>:m .-2<CR>==gi
vnoremap <S-Down> :m '>+1<CR>gv=gv
vnoremap <S-Up> :m '<-2<CR>gv=gv
" Find and Replace currently selected text
vnoremap <leader>hfr "hy:%s/<C-r>h/<C-r>h/gci<left><left><left><left>

" nnoremap <leader>p "+p
" nnoremap <leader>P "+P
"
" xnoremap <leader>p "_d"+p
" xnoremap p "_dp

" Exit search mode
nnoremap <leader>/h :noh<CR>
nnoremap <leader>/c :noh \| let@/ = "" \| call histdel("/", ".*")<CR>

" Netrw
let g:window_id_before_netrw = v:null

" File Browser toggle and keep its width consistent
function! ToggleVimExplorer()
  " ID of the window before the switch to netrw
  let g:window_id_before_netrw = win_getid()
  if exists("t:expl_buf_num")
      Lexplore
  else
      exec '1wincmd w'
      Lexplore
      " After switching to netwr buff, lets resize to 45
      vertical resize 45
      let t:expl_buf_num = bufnr("%")
  endif
endfunction

nmap <leader>fb :call ToggleVimExplorer()<CR><CR>

function! s:CloseNetrw() abort
  for bufn in range(1, bufnr('$'))
    if bufexists(bufn) && getbufvar(bufn, '&filetype') ==# 'netrw'
      silent! execute 'bwipeout ' . bufn
      if getline(2) =~# '^" Netrw '
        silent! bwipeout
      endif
      " Switch to previous window
      if g:window_id_before_netrw != v:null
        call win_gotoid(g:window_id_before_netrw)
        let g:window_id_before_netrw = v:null
      endif
      return
    endif
  endfor
endfunction

function! NetrwMapping()
  nnoremap <buffer><silent> <Esc> :call <SID>CloseNetrw()<CR>
  nnoremap <buffer><silent> <q> :call <SID>CloseNetrw()<CR>

    let g:netrw_banner = 0 " remove the banner at the top
    let g:netrw_preview = 1
    let g:netrw_liststyle = 3  " default directory view. Cycle with i
endfunction

augroup netrw_mapping
    autocmd!
    autocmd FileType netrw call NetrwMapping()
augroup END

" Close Netrw when selecting a file
augroup closeOnOpen
  autocmd!
  autocmd BufWinEnter * if getbufvar(winbufnr(winnr()), "&filetype") != "netrw"|call <SID>CloseNetrw()|endif
aug END
