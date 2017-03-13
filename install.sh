#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for folder in $(ls .config);
do
    ln -sT $DIR/.config/$folder ~/.config/$folder;
done

for file in $(find . -maxdepth 1 -type f -exec basename {} \; | grep -v install.sh);
do
    ln -sT $DIR/$file ~/$file;
done
