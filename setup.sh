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
    for configdir in $(listdirs) ; do
        mkdir -p $HOME/${configdir#./}
    done

    for dotfile in $(dotfiles) ; do
        create_symlink ${dotfile#./} $HOME
    done

    install_vscode_extenstions
}

function install_vscode_extenstions() {
    extenstions=(
        "patbenatar.advanced-new-file"
        "editorconfig.editorconfig"
        "fabiospampinato.vscode-highlight"
        "kisstkondoros.vscode-gutter-preview"
        "yzhang.markdown-all-in-one"
        "tchayen.markdown-links"
        "svsool.markdown-memo"
        "mushan.vscode-paste-image"
        "alefragnani.project-manager"
        "ms-vscode.sublime-keybindings"
        "ms-vscode.wordcount"
    )
    ask_for_confirmation "Do you want to install VsCode extenstions?"
    if answer_is_yes; then
        for ext in ${extenstions[@]}; do
            code --install-extension $ext
        done
    fi
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

function listdirs() {
    find . -type d -not -path "./.git/*" -a -not -path "." -a -not -path "./.git"
}

function dotfiles() {
    find . -type f -not -path "./.git/*" -a -not -name 'README.md' -a -not -name 'setup.sh'
}

function warn() {
    echo -e "WARN\t$1"
}
function ok()   {
    echo -e "OK\t$1"
}


main
