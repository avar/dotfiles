## Configure __git_ps1

# If there're untracked files, then a '%' will be shown next to the
# branch name.
export GIT_PS1_SHOWUNTRACKEDFILES=

# If something is stashed, then a '$' will be shown next to the branch
# name.
export GIT_PS1_SHOWSTASHSTATE=yes

# Show dirty state explicitly, way too verbose in ~/
export GIT_PS1_SHOWDIRTYSTATE=

# If you would like to see the difference between HEAD and its
# upstream, set GIT_PS1_SHOWUPSTREAM="auto".  A "<" indicates you are
# behind, ">" indicates you are ahead, and "<>" indicates you have
# diverged.
export GIT_PS1_SHOWUPSTREAM=auto

# print some useful info about the current dir
# if we're inside a git working tree, print the current git branch
# or else print the number of hardlinks in the directory
function dir_info() {
    if type git >&/dev/null; then
        if test -n "$(type -t __git_ps1)"; then
            # We can hopefully use __git_ps1 which comes with git's
            # bash completion support
            local git_info=$(__git_ps1 "%s")
            if test -n "$git_info"; then
                echo $git_info
                return 0
            fi
        else
            # Fall back on something dumb
            local git_info=$(git symbolic-ref --short HEAD 2>/dev/null)
            if test -n "$git_info"; then
                echo $git_info
                return 0
            fi
        fi
    fi

    stat --format="%U %h" .
}

function dir_color {
    echo -n $((31 + $(echo $PWD | cksum | cut -c1-3) % 6))
}

# Change the window title of X terminals 
case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/\~}\007"'
        ;;
    screen)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
        ;;
esac

# Immediately append history to ~/.bash_history so that if I e.g. kill
# screen or start a new terminal I save it / have it available.
#
# See the discussion at
# http://askubuntu.com/questions/67283/is-it-possible-to-make-writing-to-bash-history-immediate
# for some more details. This used to be:
#
#    history -a; history -c; history -r
#
# Which from re-reading that might be more performant as:
#
#   history  -a; history -n
#
# But in any case, I don't want to "echo foo" in one terminal and
# "echo bar" in another, and then have C-p in either show "foo/bar", I
# frequently have many windows that I'd like to have independent local
# history in, but I want them to be eventually consistent, which with
# just "history -a" is when I open a new terminal, not right away
# between all sessions.
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# check if we support colors
if test "$(tput colors 2>/dev/null || echo 2)" -gt 2
then
    # Colors on a per-server basis based on a simple
    # checksum. Inspired by http://geofft.mit.edu/blog/sipb/125
    __hostname_color=$((31 + $(hostname | cksum | cut -c1-3) % 6))

    PS1='\[\e[1;${__hostname_color}m\]\h\[\e[m\] \[\e[1;$(dir_color)m\]\W\[\e[m\] (\[\e[;33m\]$(dir_info)\[\e[m\]) \[\e[1;32m\]\$\[\e[m\] '

    export PERLDOC="-MPod::Text::Ansi"
else
    ## There's some bug in Emacs + TRAMP where it can't connect to a
    ## remote host if that remote host has ">" in the PS1. Maybe it's
    ## some interaction with my dotfiles. Disable for now and test
    ## later.
    #PS1='\h \W ($(dir_info)) \$ '
    PS1='\h \W (DUMMY) \$ '
fi
