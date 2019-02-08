#!/usr/bin/env bash

# Show what we are doing
#set -x

CMD_PATH="$(dirname "$(readlink -f "$0")")"

pushd "$CMD_PATH" 1>/dev/null
    if [ ! -d "bundle/Vundle.vim" ]; then
        git clone https://github.com/VundleVim/Vundle.vim bundle/Vundle.vim
    else
        pushd bundle/Vundle.vim 1>/dev/null
        git pull
        popd 1>/dev/null
    fi

    if [ ! -e "$HOME/.vimrc" ]; then
        ln -sv .vim/vimrc ~/.vimrc
    fi

    # Start vim and trigger Vundle to pull updates
    vim +PluginInstall +qall
popd 1>/dev/null
