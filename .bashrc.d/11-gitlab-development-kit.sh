#!/bin/sh

if test -d ~/g.gl/gdk/gitlab-development-kit
then
    # Install the GDK completion
    . ~/g.gl/gdk/gitlab-development-kit/support/completions/gdk.bash
fi

# Add rbenv
if which rbenv >/dev/null
then
    eval "$(rbenv init -)"
fi

# nvm, for nodejs etc.: https://github.com/nvm-sh/nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
