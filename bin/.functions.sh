#!/bin/bash

CYA="\e[36m";
YEL="\e[33m";
GRN="\e[32m";
RED="\e[31m";
RST="\e[0m";

function info  { echo -ne "[ ${GRN}info${RST}]: $*"; }
function warn  { echo -ne "[ ${YEL}warn${RST}]: $*"; }
function error { echo -ne "[${RED}error${RST}]: $*"; }
function ptest { echo -ne "[ ${CYA}test${RST}]: $*"; }

function infof  { local f=$1; shift; printf "[ ${GRN}info${RST}]: $f" "$*"; }
function warnf  { local f=$1; shift; printf "[ ${YEL}warn${RST}]: $f" "$*"; }
function errorf { local f=$1; shift; printf "[${RED}error${RST}]: $f" "$*"; }
function ptestf { local f=$1; shift; printf "[ ${CYA}test${RST}]: $f" "$*"; }

INSTALLER=""
REMOVER=""
DISTRO=""
DISTRO_DESC=""
DOCKER=""

# docker run -p 6667:6667 42wim/matterircd:latest -bind 0.0.0.0:6667 --mserver mm.sdagit.com
function id_os {
    if [ ! -x "$(which lsb_release 2>/dev/null)" ]; then
        # Manjaro/Arch derivatives
        [ -x "$(which pacman 2>/dev/null)" ] && sudo pacman -S --noconfirm lsb-release
        # Gentoo
        [ -x "$(which emerge 2>/dev/null)" ] && sudo emerge lsb-release
        # Ubuntu/Debian derivatives
        [ -x "$(which apt-get 2>/dev/null)" ] && sudo apt-get install -y lsb-release
    fi

    DISTRO="$(lsb_release -si)"
    DISTRO_DESC="$(lsb_release -sd | sed -e 's,",,g')"
    if [ "$DISTRO" == "Debian" ]; then
        INSTALLER="sudo apt-get install -y"
        REMOVER="sudo apt-get remove -y"
    fi
    if [ "$DISTRO" == "Ubuntu" ]; then
        INSTALLER="sudo apt-get install -y"
        REMOVER="sudo apt-get remove -y"
    fi
    if [ "$DISTRO" == "ManjaroLinux" ]; then
        INSTALLER="sudo pacman -S --noconfirm"
        REMOVER="sudo pacman -R --noconfirm"
    fi
    if [ "$DISTRO" == "Arch" ]; then
        INSTALLER="sudo pacman -S --noconfirm"
        REMOVER="sudo pacman -R --noconfirm"
    fi
    if [ "$DISTRO" == "Gentoo" ]; then
        INSTALLER="sudo emerge"
        REMOVER="sudo emerge -C"
    fi

    # identify if we have docker
    if [ -x "$(which docker)" ]; then
        DOCKER="$(which docker)"
    fi
}

function os_info {
    info "OS Information: $DISTRO_DESC ($DISTRO)\n"
    info "Install program: $INSTALLER\n";
    info "Remove program: $REMOVER\n";
}

function package_install {
    info "Installing package(s): $*\n"
    $INSTALLER $1
}

function package_remove {
    info "Removing package(s): $*\n"
    $REMOVER $1
}

function benchmark {
    info "Updating sysbench container...\n"
    docker pull severalnines/sysbench

    local threads="1 $(grep -c '^processor' /proc/cpuinfo) $((4 * $(grep -c '^processor' /proc/cpuinfo)))"
    local bsizes="1K 64K 256K 512K 1M"
    for thread in $threads; do
        ptestf "%-40s" "CPU ($thread threads): "
        docker run -it severalnines/sysbench sysbench cpu --threads="$thread" run \
            | grep 'events per' \
            | sed -re 's,.*second:[\ ]+([0-9.]+),\1 events/s,'
    done

    for thread in $threads; do
        for size in $bsizes; do
            ptestf "%-40s" "Memory ($thread threads; block size $size): "
            docker run -it severalnines/sysbench sysbench memory --threads="$thread" \
                --memory-block-size="$size" run \
                | grep 'MiB/sec' \
                | sed -re 's,.*\((.* MiB/sec)\),\1,'
        done
    done

    for thread in $threads; do
        ptestf "%-40s" "thread ($thread threads): "
        docker run -it severalnines/sysbench sysbench threads --threads="$thread" run \
            | grep 'number of events' \
            | sed -re 's,.*events:[\ ]+([0-9.]+),\1 events,'
    done

    #sysbench --test=cpu --cpu-max-prime=100000 run --num-threads=1 --max-requests=100
}

# Init section, validate sudo
if ! sudo true; then error "Please configure sudo access.\n"; exit 1; fi

id_os