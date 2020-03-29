#!/bin/bash
#
# @author webworker01
#
cd

git config --global user.email "lagane.thomas@gmail.com"
git config --global user.name "3cl1ps"
/home/eclips/install/nano.sh 

grep -q "^[#]*force_color_prompt=" /home/eclips/.bashrc && sed -i "/^[#]*force_color_prompt=/c\force_color_prompt=yes" /home/eclips/.bashrc
source /home/eclips/.bashrc

cat <<EOF > $HOME/.vimrc
if empty(glob('~/.vim/autoload/plug.vim')) 
silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs 
\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 
autocmd VimEnter * PlugInstall --sync | source $MYVIMRC 
endif 
call plug#begin('~/.vim/plugged') 
Plug 'neomake/neomake' 
call plug#end() 

" When writing a buffer (no delay). 
call neomake#configure#automake('w') 
" " When writing a buffer (no delay), and on normal mode changes (after 
" 750ms). 
call neomake#configure#automake('nw', 750) 
" " When reading a buffer (after 1s), and when writing (no delay). 
call neomake#configure#automake('rw', 1000) 
" " Full config: when writing or reading a buffer, and on changes in insert 
" and 
" " normal mode (after 500ms; no delay when writing). 
call neomake#configure#automake('nrwi', 500) 

filetype plugin indent on 
" show existing tab with 4 spaces width 
set tabstop=4 
" when indenting with '>', use 4 spaces width 
set shiftwidth=4 
" On pressing tab, insert 4 spaces 
set expandtab
EOF

git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
