## Include system-wide bashrc
if test -f /etc/bashrc
then
    . /etc/bashrc
fi

if test -f /etc/bash_completion
then
    # On recent Debian (late 2021-ish) __git_ps1 isn't available by
    # default, load it manually
    . /etc/bash_completion
fi

## Completion and prompt from my ~/local git
for f in \
    ~/local/share/bash-completion/completions/git \
    ~/local/lib/git-core/git-sh-prompt
do
    test -f "$f" && . "$f"
done

## Unset things in global bashrc's that I'd prefer to set myself
## later.
unset TMOUT
unset GIT_AUTHOR_NAME
unset GIT_COMMITTER_NAME

## Some regression in gnome-terminal @ 2015-08-31 that caused colors
## to stop working. I didn't see any obvious package that changed.
##
## This causes gnome-terminal to not have any colors under screen, but
## under xterm things work. So it's presumably some gnome-terminal
## bug.
##
## See also:
## - https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=723944
## - http://invisible-island.net/ncurses/ncurses.faq.html#xterm_generic
## - http://invisible-island.net/vttest/vttest-wrap.html
if test $TERM = "screen.xterm-256color"
then
    export TERM="screen"
fi

## set my PATH
maybe_add_path() {
    if [[ "$PATH" != *"$1"* && -d "$1" ]]
    then
        PATH=$1:$PATH
    fi
}

## Move $1 to the front of the PATH
move_up_in_path () {
    if [[ "$PATH" == *"$1"* ]]
    then
        PATH=$1:${PATH//:$1:/}
    fi
}

## Remove a given path from $PATH, e.g. to get rid of my custom git:
##
##    remove_from_path $(dirname $(which git)) 
remove_from_path () {
    if [[ "$PATH" == *"$1"* ]]
    then
        PATH=${PATH//:$1:/}
        PATH=${PATH//$1:/}
        PATH=${PATH//:$1/}
	export PATH
    fi	
}

# custom scripts
maybe_add_path $HOME/bin
maybe_add_path $HOME/g/misc-scripts
maybe_add_path $HOME/g/annex-distribute

# ruby
maybe_add_path /var/lib/gems/1.8/bin

# Custom binaries
maybe_add_path $HOME/local/bin

# Only if the screen configuration (dsgit) added it already
move_up_in_path $HOME/g/git/bin-wrappers

# Use less shitty stack traces in LSAN at the cost of a bit of
# (sometimes ~2-10%) slowdown.
export LSAN_OPTIONS=fast_unwind_on_malloc=0

# Custom commands
maybe_add_path $HOME/g/hyperfine/target/debug
maybe_add_path $HOME/g/git-hyperfine

# custom blead compile
maybe_add_path ~/perl5/installed/bin

# other custom compilations
maybe_add_path ~/local/bin

if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# away with old aliases
\unalias -a

# Include alias x=y statements
. ~/.aliases

# Include ~/.{aliases,bashrc}.d/ config files
for dir in bashrc.d aliases.d
do
    if [ -d ~/.$dir ]; then
        for i in ~/.$dir/*.sh; do
            if [ -r $i ]; then
                . $i
            fi
        done
        unset i
    fi
done

# some nice shell options
shopt -s checkwinsize cdspell histappend no_empty_cmd_completion

# GNU it
export EDITOR="emacsclient --alternate-editor emacs"

# So ack(1) will use unicode, this probably fixes other stuff too that
# didn't heed my locale
#export PERL_UNICODE=SDAL

# some nice less(1) options
export LESS="--ignore-case --LONG-PROMPT --QUIET --chop-long-lines --RAW-CONTROL-CHARS --no-init"

# For App::Nopaste
export NOPASTE_SERVICES="Gist Pastie"

# keep a long history without duplicates
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL="ignoredups"
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "

# ignore some boring stuff. The " *" bit ignores all command lines
# starting with whitespace, useful to selectively avoid the history
export HISTIGNORE="ls:cd:cd ..:..*: *"

# Sync files based on content. Useful for dynamically changing files.
function scp {
    rsync --rsh=ssh --archive --no-group --human-readable --progress "$@"
}

# Append to files based on file size. Useful large, static or append-only
# files since it skips the expensive hash check. Also retry the transfer
# if it times out.
function leech {
    cmd="rsync --rsh=ssh --append --archive --no-group --human-readable --progress"
    $cmd "$@"
    while [[ $? == 30 ]]; do sleep 5 && $cmd "$@"; done
}

function use_icelandic {
    # Use Icelandic
    unset LANGUAGE
    export LANG=is_IS.UTF-8
}

# debian upgrade
function dug {
    sudo apt update
    sudo apt upgrade
    sudo apt dist-upgrade
}

function dud {
    (
        cd ~/
        chmod 600 ~/.ssh/config

        # If the only modification to ~/.gitconfig is changing the
        # E-Mail, just overwrite it because 
        if git diff -U0 | grep '^[-+][^-+]' | grep -q -v email
        then
            echo "You have local changes to ~/, commit them:"
            git --no-pager diff
        else
            echo "Nuking local E-Mail only changes to ~/.gitconfig"
            git --no-pager diff
            git checkout -f ~/.gitconfig
        fi
        git pull
        . ~/.bashrc
    )
}
