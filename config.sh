#!/usr/bin/env bash

# Things to get added:
#   xfce4-terminal config

# Programs that I use
#  - tmux
#  - vim
#  - vifm
#  - nitrogen
#  - i3lock
PROGRAMS_Debian="tmux vim vifm nitrogen i3lock"
PROGRAMS_Ubuntu="tmux vim vifm nitrogen i3lock"
PROGRAMS_ManjaroLinux="tmux vim vifm nitrogen i3lock"
PROGRAMS_Arch="tmux vim vifm nitrogen i3lock"
PROGRAMS_Gentoo="tmux vim vifm nitrogen i3lock"

if [ ! -x "$(which lsb_release 2>/dev/null)" ]; then
    # Arch is the only one so far that does not include lsb_release
    [ -x "$(which pacman 2>/dev/null)" ] && sudo pacman -S --noconfirm lsb-release
    # Gentoo joins arch with in failure to include lsb_release
    [ -x "$(which emerge 2>/dev/null)" ] && sudo emerge lsb-release

fi

DISTRO="$(lsb_release -si)"
SELECTED_PROGRAMS="PROGRAMS_$DISTRO"
eval SELECTED="\$$SELECTED_PROGRAMS"

install_programs() {
    for p in $SELECTED; do
        if [ ! -x "$(which $p 2>/dev/null)" ]; then
            if [ "$DISTRO" == "Debian" ]; then
                info "Installing $p..."
                sudo apt-get install -y $p
            fi
            if [ "$DISTRO" == "Ubuntu" ]; then
                info "Installing $p..."
                sudo apt-get install -y $p
            fi
            if [ "$DISTRO" == "ManjaroLinux" ]; then
                info "Installing $p..."
                sudo pacman -S --noconfirm $p
            fi
            if [ "$DISTRO" == "Arch" ]; then
                info "Installing $p..."
                sudo pacman -S --noconfirm $p
            fi
            if [ "$DISTRO" == "Gentoo" ]; then
                info "Installing $p..."
                sudo emerge $p
            fi
        fi
    done
}

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

    # generally gnome-terminal (ubuntu patched) or xfce4-terminal

    # Set up gnome-terminal (requires dconf)
    _setup_gnome_terminal;
}

_setup_gnome_terminal() {
    # Make sure it's available
    if [ -x "$(which gnome-terminal)" ] && [ -x "$(which dconf)" ]; then
        info "Setting up gnome-terminal..."
        KEY="/org/gnome/terminal/legacy/profiles:/"
        # Get profile
        PROFILE="$(dconf list "$KEY" | head -n1)"
        info "Configuring profile ($PROFILE)..."

        # basic settings
        dconf write "${KEY}${PROFILE}use-theme-colors" "false"
        dconf write "${KEY}${PROFILE}use-theme-transparency" "false"
        dconf write "${KEY}${PROFILE}use-transparent-background" "true"
        dconf write "${KEY}${PROFILE}scrollbar-policy" "'never'"
        dconf write "${KEY}${PROFILE}bold-is-bright" "true"

        # colors
        dconf write "${KEY}${PROFILE}background-color" "'rgb(0,0,0)'"
        dconf write "${KEY}${PROFILE}foreground-color" "'rgb(255,255,255)'"
        dconf write "${KEY}${PROFILE}background-transparency-percent" "10"
        # copy of the tango palette
        dconf write "${KEY}${PROFILE}palette" "['rgb(15,16,17)', 'rgb(99,33,33)', 'rgb(78,154,6)', 'rgb(196,160,0)', 'rgb(52,101,164)', 'rgb(117,80,123)', 'rgb(6,152,154)', 'rgb(211,215,207)', 'rgb(85,87,83)', 'rgb(239,41,41)', 'rgb(138,226,52)', 'rgb(252,233,79)', 'rgb(114,159,207)', 'rgb(173,127,168)', 'rgb(52,226,226)', 'rgb(238,238,236)']"

        # font
        dconf write "${KEY}${PROFILE}use-system-font" "false"
        dconf write "${KEY}${PROFILE}font" "'Liberation Mono for Powerline 10'"

    fi
}

install_programs;
setup_vim;
setup_awesome;
setup_zsh;
setup_terminals;
