" Use vim-plug plugin manager
call plug#begin('~/.vim/plugged')

" UI/UX
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'

" Editing
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'

" Code
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" Theme
syntax on
set background=dark
colorscheme gruvbox

" Basics
set number
set relativenumber
set tabstop=4 shiftwidth=4 expandtab
set smartindent
set hidden
set clipboard=unnamedplus
set mouse=a

" NERDTree toggle
nnoremap <C-n> :NERDTreeToggle<CR>
