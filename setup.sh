#!/bin/bash

# Copied from https://github.com/plexus/dotfiles/blob/master/connect-the-dots

answer_is_yes() {
    [[ "$REPLY" =~ ^[Yy]$ ]] \
        && return 0 \
        || return 1
}

ask_for_confirmation() {
    echo "$1 (y/n) "
    read -r -n 1
    printf "\n"
}

function main() {
    for configdir in $(configdirs) ; do
        symlink_dir_recursive $configdir $HOME
    done
}

function symlink_dir_recursive() {
    local dotdir=${1#./}
    local dstdir=$2

    local line=$(echo $dotdir | tr "/" "\n")
    local arr=($line)
    local dotfile=""

    for x in ${arr[@]}
    do
        if [[ "$dotfile" == "" ]]; then
            dotfile="$x"
        else
            dotfile="$dotfile/$x"
        fi

        if [[ "$dotdir" == "$dotfile" ]]; then
            create_symlink $dotfile $HOME
            break
        fi

        if [[ ! -d "$HOME/$dotfile" ]]; then
            warn "dir: $HOME/$dotfile don't exist"
            mkdir $HOME/$dotfile
        fi
    done
}

function create_symlink() {
    local dotfile=$1
    local dstdir=$2
    local target=$(readlink -f $dstdir/$dotfile)

    if [[ "$target" == "`dotdir $dotfile`" ]]; then
        ok "$dotfile \t already linked"
        return
    fi

    if [[ -e "$dstdir/$dotfile" ]]; then
        warn "$dotfile \t can't create symlink, regular file is in the way."
        ask_for_confirmation "Do you want to overwrite $dstdir/$dotfile?"
        if answer_is_yes; then
            cp -iv $dstdir/$dotfile "$dstdir/$dotfile.bak"
            rm -i $dstdir/$dotfile
        else
            return
        fi
    fi

    ln -s "`dotdir`/$dotfile" "$dstdir/$dotfile"
    ok "$dotfile \t creating link"
}

function dotdir() {
    cd `dirname "${BASH_SOURCE[0]}"` && echo "`pwd`/$1"
}

function configdirs() {
    find . -type f -not -path "./.git/*" -a -not -name 'README.md' -a -not -name 'setup.sh'
}

function warn() {
    echo -e "WARN\t$1"
}
function ok()   {
    echo -e "OK\t$1"
}


main
