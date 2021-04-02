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

function infof  { printf "[ ${GRN}info${RST}]: %-30s" "$*"; }
function warnf  { printf "[ ${YEL}warn${RST}]: %-30s" "$*"; }
function errorf { printf "[${RED}error${RST}]: %-30s" "$*"; }
function ptestf { printf "[ ${CYA}test${RST}]: %-30s" "$*"; }

INSTALLER=""
REMOVER=""
UPDATER=""
DISTRO=""
DISTRO_DESC=""
DOCKER=""

function check_cmd {
    # determine if given command is available
    CMD=$1
    if [ "$(command -v "$CMD")x" != "x" ]; then
        return
    fi

    error "command not found: $CMD\n"
    exit 1;
}

# docker run -p 6667:6667 42wim/matterircd:latest -bind 0.0.0.0:6667 --mserver mm.sdagit.com
function id_os {
    if [ ! -x "$(command -v lsb_release 2>/dev/null)" ]; then
        # Manjaro/Arch derivatives
        [ -x "$(command -v pacman 2>/dev/null)" ] && sudo pacman -S --noconfirm lsb-release
        # Gentoo
        [ -x "$(command -v emerge 2>/dev/null)" ] && sudo emerge lsb-release
        # Ubuntu/Debian derivatives
        [ -x "$(command -v apt-get 2>/dev/null)" ] && sudo apt-get install -y lsb-release
    fi

    DISTRO="$(lsb_release -si)"
    DISTRO_DESC="$(lsb_release -sd | sed -e 's,",,g')"
    if [ "$DISTRO" == "Debian" ] || [ "$DISTRO" == "Ubuntu" ]; then
        INSTALLER="sudo apt-get install -y"
        UPDATER="sudo apt-get upgrade"
        REMOVER="sudo apt-get remove -y"
    fi
    if [ "$DISTRO" == "Arch" ] || \
       [ "$DISTRO" == "ManjaroLinux" ] || \
       [ "$DISTRO" == "ArcoLinux" ] || \
       [ "$DISTRO" == "Artix" ]; then
        INSTALLER="sudo pacman -S --noconfirm"
        UPDATER="sudo pacman -Syu"
        REMOVER="sudo pacman -R --noconfirm"
    fi
    if [ "$DISTRO" == "Gentoo" ]; then
        INSTALLER="sudo emerge"
        UPDATER="sudo emerge -aDuv @world"
        REMOVER="sudo emerge -C"
    fi

    # identify if we have docker
    if [ -x "$(command -v docker)" ]; then
        DOCKER="$(command -v docker)"
    fi
}

function system_info {
    check_cmd "bc"
    check_cmd "dmidecode"

    PROC_NAME="$(grep '^model name' /proc/cpuinfo|cut -d' ' -f3- |head -1)"
    PROC_CORES="$(grep -c '^processor' /proc/cpuinfo)";
    MEMORY=$(printf "%.2f GB" "$(echo "$(grep '^MemTotal' /proc/meminfo|awk '{print $2}')" / 1000 / 1000 | bc -l)")
    MEMSPEED="$(sudo dmidecode --type 17 |grep -v Unknown |grep Speed: |head -n1 | sed -re 's,.*Speed: (.*),\1,')"
    VIDEO=$(lspci |grep VGA | sed -e 's,.*: ,,')

    info "System Information:\n";
    info "\tProcessor: $PROC_NAME ($PROC_CORES cores)\n";
    info "\tMemory: $MEMORY ($MEMSPEED)\n";
    info "\tVideo: $VIDEO\n";
    info "\tKernel: $(uname -mr)\n";
    info "\tUptime: $(uptime)\n";
}

function os_info {
    info "OS Information:\n";
    info "\t$DISTRO_DESC $(lsb_release -cs) ($DISTRO)\n"
    info "\tInstall program: $INSTALLER\n";
    info "\tRemove program: $REMOVER\n";
    info "\tUpdate program: $UPDATER\n";
    if [ "${DOCKER}x" != "x" ]; then
        info "\tDocker: $($DOCKER --version | sed 's/^.*version //')\n";
    fi
    info "\tShell: $($(getent passwd "$USER"|cut -d: -f7) --version|head -1)\n";
}

function package_install {
    info "Installing package(s): $*\n"
    $INSTALLER "$1"
}

function system_update {
    info "Updating system...\n";
    $UPDATER
}

function command_update {
    info "Updating command scripts...\n";
    DOCKER_MACHINE_URL="https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-$(uname -s)-$(uname -m)"
    if [ ! -e "$HOME/bin/docker-machine" ]; then
        curl -L# -o "$HOME/bin/docker-machine" "$DOCKER_MACHINE_URL";
        chmod +x "$HOME/bin/docker-machine"
    fi

    DOCKER_MACHINE_KVM_URL="https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.7.0/docker-machine-driver-kvm"
    if [ ! -e "$HOME/bin/docker-machine-driver-kvm" ]; then
        curl -L# -o "$HOME/bin/docker-machine-driver-kvm" "$DOCKER_MACHINE_KVM_URL"
        chmod +x "$HOME/bin/docker-machine-driver-kvm"
    fi
}

function package_remove {
    info "Removing package(s): $*\n"
    $REMOVER "$1"
}

function disk_benchmark {
    ptestf "Running read test (bs 128k): "
    RBENCH=$(fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=128k --numjobs=4 --size=256M --runtime=600  --group_reporting --output-format=json)
    echo $(($(echo "$RBENCH"|jq '.jobs[0].read.bw') / 1000)) "MB/s, " $(echo "$RBENCH"|jq '.jobs[0].read.iops') " IOPS"
    rm -f seqread.*

    ptestf "Running write test (bs 128k): "
    WBENCH=$(fio --name=seqwrite --rw=write --direct=1 --ioengine=libaio --bs=128k --numjobs=4 --size=256M --runtime=600 --group_reporting --output-format=json)
    echo $(($(echo "$WBENCH"|jq '.jobs[0].write.bw') / 1000)) "MB/s, " $(echo "$WBENCH"|jq '.jobs[0].write.iops') " IOPS"
    rm -f seqwrite.*

    ptestf "Running read test (bs 256k): "
    RBENCH=$(fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=256k --numjobs=4 --size=256M --runtime=600  --group_reporting --output-format=json)
    echo $(($(echo "$RBENCH"|jq '.jobs[0].read.bw') / 1000)) "MB/s, " $(echo "$RBENCH"|jq '.jobs[0].read.iops') " IOPS"
    rm -f seqread.*

    ptestf "Running write test (bs 256k): "
    WBENCH=$(fio --name=seqwrite --rw=write --direct=1 --ioengine=libaio --bs=256k --numjobs=4 --size=256M --runtime=600 --group_reporting --output-format=json)
    echo $(($(echo "$WBENCH"|jq '.jobs[0].write.bw') / 1000)) "MB/s, " $(echo "$WBENCH"|jq '.jobs[0].write.iops') " IOPS"
    rm -f seqwrite.*
}

function benchmark {
    info "Updating sysbench container...\n"
    check_cmd "docker"

    sudo docker pull -q severalnines/sysbench

    system_info
    echo
    local threads;
    local bsizes;

    threads="1 $(grep -c '^processor' /proc/cpuinfo) $((4 * $(grep -c '^processor' /proc/cpuinfo)))"
    bsizes="1K 64K 256K 512K 1M"

    disk_benchmark;

    ptestf "CPU Int (threads:events/s):"
    for thread in $threads; do
        printf "%4s: %8.2f  " "$thread" \
        "$(docker run -it severalnines/sysbench sysbench cpu --threads="$thread" run \
            | grep 'events per' \
            | sed -re "s,.*second:[\ ]+([0-9.]+),\1," | tr -d '\r\n')"
    done
    echo

    ptestf "thread (threads:event/s): "
    for thread in $threads; do
        printf "%4s: %8.2f  " "$thread" \
        "$(docker run -it severalnines/sysbench sysbench threads --threads="$thread" run \
            | grep 'number of events' \
            | sed -re 's,.*events:[\ ]+([0-9.]+),\1,' | tr -d '\r\n')"
    done
    echo

    for thread in $threads; do
        ptestf "Memory ($thread thread - MB/s): "
        for size in $bsizes; do
            printf "%4s: %8.2f  " "$size" \
            "$(docker run -it severalnines/sysbench sysbench memory --threads="$thread" \
                --memory-block-size="$size" run \
                | grep 'MiB/sec' \
                | sed -re "s,.*\((.*) MiB/sec\),\1," | tr -d '\r\n')"
        done
        echo
    done
}

# Init section, validate sudo
if ! sudo true; then error "Please configure sudo access.\n"; exit 1; fi

id_os
