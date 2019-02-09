#!/usr/bin/env bash

# Things to get added:
#   xfce4-terminal config

# precheck stuff
CMD_PATH="$(dirname "$(readlink -f "$0")")"
GIT="$(which git)"

[ ! -z "$GIT" ] || exit

# basic colors
RED="\e[31m";
GRN="\e[32m";
YEL="\e[33m";
RST="\e[0m";

# basic output handlers
info()  { printf "[${GRN}info ${RST}]  $@\n"; }
warn()  { printf "[${YEL}warn ${RST}]  $@\n"; }
error() { printf "[${RED}error${RST}]  $@\n"; exit; }

do_git() {
    local git=$1
    local path=$2

    # make sure parent dir exists
    if [ ! -d "$(dirname "$2")" ]; then
        mkdir "$(dirname "$2")"
    fi

    if [ -d "$path" ]; then
        git_update "$path"
    else
        git_clone "$git" "$path"
    fi
}

git_clone() {
    local git=$1
    local path=$2

    info "Cloning $git..."
    $GIT clone "$git" "$path"
    if [ "$?" -ne 0 ]; then
        error "Clone failed."
    fi
}

git_update() {
    local path=$1;

    info "Pulling $git..."
    pushd "$path" 1>/dev/null && git pull && popd 1>/dev/null;
    if [ "$?" -ne 0 ]; then
        error "Pull failed."
    fi
}

setup_zsh() {
    do_git "https://github.com/zsh-users/zsh-syntax-highlighting" "$CMD_PATH/.zsh/syntax-highlighting"
    do_git "https://github.com/zsh-users/zsh-autosuggestions" "$CMD_PATH/.zsh/autosuggestions"
}

setup_vim() {
    info "Running setup for vim..."
    "$CMD_PATH/.vim/setup.sh"
    [ -L "$CMD_PATH/.vimrc" ] || ln -sv .vim/vimrc "$CMD_PATH/.vimrc"
}

setup_awesome() {
    do_git "https://github.com/lcpz/lain" "$CMD_PATH/.config/awesome/lain"
}

setup_terminals() {
    do_git "https://github.com/powerline/fonts" "$HOME/.local/powerline-fonts"
    $HOME/.local/powerline-fonts/install.sh
}

setup_vim;
setup_awesome;
setup_zsh;
setup_terminals;
