#!/usr/bin/env bash

# Things to get added:
#   xfce4-terminal config

# Programs that I use
#  - tmux
#  - vim
#  - vifm
#  - nitrogen
#  - i3lock
export PROGRAMS_Debian="curl git zsh tmux vim vifm"
export PROGRAMS_Ubuntu="curl git zsh tmux vim vifm"
export PROGRAMS_ManjaroLinux="curl git zsh tmux vim vifm"
export PROGRAMS_Arch="curl git zsh tmux vim vifm"
export PROGRAMS_Gentoo="curl git zsh tmux vim vifm"

if [ ! -x "$(command -v lsb_release)" ]; then
    # Arch is the only one so far that does not include lsb_release
    [ -x "$(command -v pacman 2>/dev/null)" ] && sudo pacman -S --noconfirm lsb-release
    # Gentoo joins arch with in failure to include lsb_release
    [ -x "$(command -v emerge 2>/dev/null)" ] && sudo emerge lsb-release

fi

DISTRO="$(lsb_release -si)"
SELECTED_PROGRAMS="PROGRAMS_$DISTRO"
eval SELECTED="\$$SELECTED_PROGRAMS"

install_programs() {
    for p in $SELECTED; do
        if [ ! -x "$(command -v "$p" 2>/dev/null)" ]; then
            if [ "$DISTRO" == "Debian" ]; then
                info "Installing $p..."
                sudo apt-get install -y "$p"
            fi
            if [ "$DISTRO" == "Ubuntu" ]; then
                info "Installing $p..."
                sudo apt-get install -y "$p"
            fi
            if [ "$DISTRO" == "ManjaroLinux" ]; then
                info "Installing $p..."
                sudo pacman -S --noconfirm "$p"
            fi
            if [ "$DISTRO" == "Arch" ]; then
                info "Installing $p..."
                sudo pacman -S --noconfirm "$p"
            fi
            if [ "$DISTRO" == "Gentoo" ]; then
                info "Installing $p..."
                sudo emerge "$p"
            fi
        fi
    done
}

# precheck stuff
CMD_PATH="$(dirname "$(readlink -f "$0")")"
GIT="$(command -v git)"

[ -n "$GIT" ] || exit

# basic colors
RED="\e[31m";
GRN="\e[32m";
YEL="\e[33m";
RST="\e[0m";

# basic output handlers
info()  { echo -e "[${GRN}info ${RST}] $*"; }
warn()  { echo -e "[${YEL}warn ${RST}] $*"; }
error() { echo -e "[${RED}error ${RST}] $*"; }

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
    if ! $GIT clone --depth 1 "$git" "$path"; then
        error "Clone failed."
    fi
}

git_update() {
    local path=$1;

    info "Pulling $git..."
    pushd "$path" 1>/dev/null || exit
    if ! git pull; then
        error "Pull failed."
    fi
    popd 1>/dev/null || exit
}

setup_zsh() {
    do_git "https://github.com/zsh-users/zsh-syntax-highlighting" "$CMD_PATH/.zsh/syntax-highlighting"
    do_git "https://github.com/zsh-users/zsh-autosuggestions" "$CMD_PATH/.zsh/autosuggestions"
}

setup_vim() {
    info "Running setup for vim..."
    "$CMD_PATH/.vim/setup.sh"
    [ -L "$CMD_PATH/.vimrc" ] || ln -sv .vim/vimrc "$CMD_PATH/.vimrc"

    info "Updating plugins for vim..."
    vim +PluginUpdate +qall
}

setup_awesome() {
    do_git "https://github.com/lcpz/lain" "$CMD_PATH/.config/awesome/lain"
}

setup_terminals() {
    # grab powerline fonts
    info "Installing powerline fonts..."
    do_git "https://github.com/powerline/fonts" "$HOME/.local/powerline-fonts"
    "$HOME/.local/powerline-fonts/install.sh"

    # grab nerd fonts some specific nerd fonts
    for font in Hack FiraCode FiraMono Mononoki UbuntuMono LiberationMono; do
        info "Installing $font Nerd Font..."
        curl -OL# https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/$font.zip
        unzip -q -o $font.zip -d "$HOME/.local/share/fonts"
        rm -v $font.zip
    done

    # refresh font cache
    info "Clearing font cache..."
    fc-cache -f

    # Set up gnome-terminal (requires dconf)
    _setup_gnome_terminal;
}

_setup_gnome_terminal() {
    # Make sure it's available
    if [ -x "$(command -v gnome-terminal)" ] && [ -x "$(command -v dconf)" ]; then
        info "Setting up gnome-terminal..."
        KEY="/org/gnome/terminal/legacy/profiles:/"
        # Get profile
        PROFILE="$(dconf list "$KEY" | head -n1)"
        info "Configuring profile ($PROFILE)..."

        # basic settings
        dconf write "${KEY}${PROFILE}use-theme-colors" "false"
        dconf write "${KEY}${PROFILE}use-theme-transparency" "false"
        dconf write "${KEY}${PROFILE}use-transparent-background" "true"
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

        # disable menubar and scroll
        dconf write "/org/gnome/terminal/legacy/default-show-menubar" "false"
        dconf write "${KEY}${PROFILE}scrollbar-policy" "'never'"
    fi
}

install_programs;
setup_vim;
setup_awesome;
setup_zsh;
setup_terminals;
