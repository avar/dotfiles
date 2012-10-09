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
# if we're inside an svn working directory, print the current svn revision
# or else print the total size of all files in the directory
function dir_info() {
    # Test SVN first, because I'm more likely to have a svn checkout
    # inside a git repository (e.g. my ~/ in Git) than the other way
    # around.
    if test -f .svn/entries; then
        # Performance hack, calling svn info takes longer than just
        # grabbing the fourth line from .svn/entries
        local svn_rev=$(sed '4q;d' .svn/entries)
        
        if test -n $svn_rev; then
            echo "r$svn_rev"
            return 0
        fi
    fi

    if type git >&/dev/null; then
        # Include my copy of the git-prompt.sh
        . ~/.bashrc.d/contrib/git-prompt.sh

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
            local git_info=$(git symbolic-ref HEAD 2>/dev/null | sed -e 's!refs/heads/!!')
            if test -n "$git_info"; then
                echo $git_info
                return 0
            fi
        fi
    fi

    ls -Alhs | head -n1 | cut -d' ' -f2
}

if ls --help >&/dev/null 2>&1 | grep -q group-directories-first; then
    group_dirs=" --group-directories-first"
else
    group_dirs=
fi

# check if we support colors
if type tput >/dev/null &&
    tput_colors="$(tput colors)" &&
    test -n "$tput_colors" &&
    test "$tput_colors" -gt 2
then
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls="ls$group_dirs --color=auto"

        # old versions of tree(1) don't use colors by default
        alias tree="tree -C"
    fi

    # Colors on a per-server basis based on a simple
    # checksum. Inspired by http://geofft.mit.edu/blog/sipb/125
    __hostname_color=$((31 + $(hostname | cksum | cut -c1-3) % 6))

    if [[ ${EUID} == 0 ]] ; then
        PS1='\[\e[1;${__hostname_color}m\]\h\[\e[m\] \[\e[1;34m\]\W\[\e[m\] (\[\e[;33m\]$(dir_info)\[\e[m\]) \[\e[1;31m\]\$\[\e[m\] '
    else
        PS1='\[\e[1;${__hostname_color}m\]\h\[\e[m\] \[\e[1;34m\]\W\[\e[m\] (\[\e[;33m\]$(dir_info)\[\e[m\]) \[\e[1;32m\]\$\[\e[m\] '
    fi

    export PERLDOC="-MPod::Text::Ansi"

    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias rgrep='rgrep --color=auto'
else
    ## There's some bug in Emacs + TRAMP where it can't connect to a
    ## remote host if that remote host has ">" in the PS1. Maybe it's
    ## some interaction with my dotfiles. Disable for now and test
    ## later.
    #PS1='\h \W ($(dir_info)) \$ '
    PS1='\h \W (DUMMY) \$ '
    alias ls="ls$group_dirs"
fi
