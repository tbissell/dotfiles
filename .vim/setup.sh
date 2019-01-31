#!/usr/bin/env bash

# Show what we are doing
set -x

CMD_PATH="$(dirname "$(readlink -f "$0")")"

pushd "$CMD_PATH"
    if [ ! -d "bundle/Vundle.vim" ]; then
        git clone https://github.com/VundleVim/Vundle.vim bundle/Vundle.vim
    else
        pushd bundle/Vundle.vim
        git pull
        popd
    fi

    if [ ! -e "$HOME/.vimrc" ]; then
        ln -sv .vim/vimrc ~/.vimrc
    fi

    # Start vim and trigger Vundle to pull updates
    vim +PluginInstall +qall
popd
