#!/usr/bin/env bash

# Show what we are doing
set -x

# Update vundle sub-module
git submodule init
git submodule update

# Unlink vundle checkout from specific checkout
# to the master branch
pushd bundle/Vundle.vim
git checkout master
popd

if [ ! -e "~/.vimrc" ]; then
    ln -sv .vim/vimrc ~/.vimrc
fi

# Start vim and trigger Vundle to pull updates
vim +PluginInstall +qall
