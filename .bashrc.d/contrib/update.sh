#!/bin/sh

for f in git-completion.bash git-prompt.sh
do
    wget https://github.com/git/git/raw/master/contrib/completion/$f -O $f
done
