#!/bin/bash

# Copied from https://github.com/plexus/dotfiles/blob/master/connect-the-dots

function main() {
    for dotfile in $(dotfiles) ; do
        if [[ -L "$HOME/$dotfile" ]]; then
            check_existing_symlink $dotfile $HOME
        else
            create_symlink_if_possible $dotfile $HOME
        fi
    done

    # for configdir in $(configdirs) ; do
    #     if [[ -L "$HOME/.config/$configdir" ]]; then
    #         check_existing_symlink $configdir $HOME/.config/
    #     else
    #         create_symlink_if_possible $configdir $HOME/.config/
    #     fi
    # done
}

function check_existing_symlink() {
    local dotfile=$1
    local dstdir=$2
    local target=$(readlink -f $dstdir/$dotfile)

    if [[ "$target" != "`dotdir $dotfile`" ]]; then
        warn "$dotfile \t symlink points elsewhere -> $target"
    else
        ok "$dotfile \t already linked"
    fi
}

function create_symlink_if_possible() {
    local dotfile=$1
    local dstdir=$2

    if [[ -e "$dstdir/$dotfile" ]]; then
        warn "$dotfile \t can't create symlink, regular file is in the way."
    else
        ok "$dotfile \t creating link"
        ln -s "`dotdir $dotfile`" "$dstdir"
    fi
}

function dotdir() {
    cd `dirname "${BASH_SOURCE[0]}"` && echo "`pwd`/$1"
}

function dotfiles() {
    find `dotdir` -maxdepth 1 -type f -name '.*' -not -name '.git' -printf '%f\n'
}

function configdirs() {
    find `dotdir`/.config/ -maxdepth 1 -printf '%f\n'
}

function warn() {
    echo -e "WARN\t$1"
}
function ok()   {
    echo -e "OK\t$1"
}


main
