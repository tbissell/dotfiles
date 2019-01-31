#!/usr/bin/env bash

# Things to get added:
#   xfce4-terminal config

CMD_PATH="$(dirname "$(readlink -f "$0")")"

setup_vim() {
    "$CMD_PATH/.vim/setup.sh"
    [ -L "$CMD_PATH/.vimrc" ] || ln -sv .vim/vimrc "$CMD_PATH/.vimrc"
}

setup_awesome() {
    if [ ! -d "$CMD_PATH/.config/awesome/lain" ]; then
        git clone https://github.com/lcpz/lain "$CMD_PATH/.config/awesome/lain"
    else
        pushd "$CMD_PATH/.config/awesome/lain"
        git pull
        popd
    fi
}

setup_vim;
setup_awesome;
