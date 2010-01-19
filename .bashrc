export PATH=$PATH:$HOME/g/misc-scripts:$HOME/g/rtmpdump

if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# away with old aliases
\unalias -a

# disable software flow control
stty -ixon

# programmable completion
if [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

# Change the window title of X terminals 
case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
        ;;
    screen)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
        ;;
esac

# print some useful info about the current dir
# if we're inside a git working tree, print the current git branch
# if we're inside an svn working directory, print the current svn revision
# or else print the total size of all files in the directory
function dir_info() {
    if type git >&/dev/null; then
        local git_branch=$(git symbolic-ref HEAD 2>/dev/null | sed -e 's/refs\/heads\///')
        if [[ -n $git_branch ]]; then
            echo $git_branch
            return 0
        fi
    fi

    if type svn >&/dev/null; then
        local svn_rev=$(svn info 2>/dev/null | grep ^Revision | awk '{ print $2 }')
        if [[ -n $svn_rev ]]; then
            echo "r$svn_rev"
            return 0
        fi
    fi
    
    ls -Ahs|head -n1|awk '{print $2}'
}

if ls --help|grep group-directories-first >&/dev/null; then
    group_dirs=" --group-directories-first"
else
    group_dirs=
fi

# check if we support colors
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls="ls$group_dirs --color=auto"

        # old versions of tree(1) don't use colors by default
        alias tree="tree -C"
    fi

    if [[ ${EUID} == 0 ]] ; then
        PS1='\[\e[1;35m\]\h\[\e[m\] \[\e[1;34m\]\W\[\e[m\] (\[\e[;33m\]$(dir_info)\[\e[m\]) \[\e[1;31m\]\$\[\e[m\] '
    else
        PS1='\[\e[1;35m\]\h\[\e[m\] \[\e[1;34m\]\W\[\e[m\] (\[\e[;33m\]$(dir_info)\[\e[m\]) \[\e[1;32m\]\$\[\e[m\] '
    fi

    export PERLDOC="-MPod::Text::Ansi"

    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias rgrep='rgrep --color=auto'
else
    PS1='\h \W ($(dir_info)) \$ '
    alias ls="ls$group_dirs"
fi

# some nice shell options
shopt -s checkwinsize cdspell histappend no_empty_cmd_completion

alias pd=perldoc
alias pdf='perldoc -f'
alias g=git
alias ec=emacsclient
alias perl6="~/g/rakudo/perl6"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ll="ls -lh"
alias d2u="sed 's/$//'"
alias u2d="sed 's/$//'"
alias lsofnames="lsof | awk '!/^\$/ && /\// { print \$9 }' | sort -u"
alias myip="wget -q -O- 'http://www.moanmyip.com/' | perl -0777 -pe 's[.*<div class=\"ip\">(.*?)</div>.*][\$1\n]s'"
alias mmyip="mplayer http://moanmyip.com/output/\$(myip).mp3"

# From jrockway
alias perlfunc="perldoc -f"
alias lperl="perl -Ilib"
function lbperl {
    perl -Ilib "bin/$1";
}

if [[ "$TERM" == "linux" ]]; then
    if type conpalette >&/dev/null; then
        conpalette tango-dark
    fi
fi

# So ack(1) will use unicode, this probably fixes other stuff too that
# didn't heed my locale
#export PERL_UNICODE=SDAL

# some nice less(1) options
export LESS="iMQRS"

# For App::Nopaste
export NOPASTE_SERVICES="Gist Pastie"

# keep a long history without duplicates
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL="ignoreboth"
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "

# ignore some boring stuff. The " *" bit ignores all command lines
# starting with whitespace, useful to selectively avoid the history
export HISTIGNORE="ls:cd:cd ..:..*: *"

# ignore these while tab-completing
export FIGNORE="CVS:.svn:.git"

export EDITOR="emacsclient"
alias mg=$EDITOR
alias vi=$EDITOR
alias vim=$EDITOR

# use my locally installed Perl modules where available
eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib 2>/dev/null)

# do an ls after every successful cd
function cd {
    builtin cd "$@" && ls
}

# recursive mkdir and cd if successful
function mkcd {
    mkdir -p "$@" && builtin cd "$@"
}

# Sync files based on content. Useful for dynamically changing files.
function scp {
    rsync --rsh=ssh --archive --human-readable --progress "$@"
}

# Append to files based on file size. Useful large, static or append-only
# files since it skips the expensive hash check. Also retry the transfer
# if it times out.
function leech {
    cmd="rsync --rsh=ssh --append --archive --human-readable --progress"
    $cmd "$@"
    while [[ $? == 30 ]]; do sleep 5 && $cmd "$@"; done
}

# delete untracked files/dirs
function svn_clean {
    svn status "$1" | grep '^\?' | cut -c8- | \
    while read fn
        do echo "$fn"
        rm -rf "$fn"
    done
}

# do an svn update and show the log messages since the last update.
function svn_uplog {
    local old_revision=$(svn info $@ | grep ^Revision | awk '{ print $2 }')
    local first_update=$((${old_revision} + 1))

    svn up -q $@
    local new_revision=$(svn info $@ | grep ^Revision | awk '{ print $2 }')
    if [[ ${new_revision} -gt ${old_revision} ]]
    then
            svn log -v -rHEAD:${first_update} $@
    else
            echo "No changes."
    fi
}

function podcast_sync {
    if [ $(mount | grep -c /media/SANSA) -gt 0 ]; then
        find /media/SANSA/PODCASTS/ -type f -name '*.pdf' -exec rm -v {} \;
        find /media/SANSA/PODCASTS/ -type f -name '*.mp4' -exec rm -v {} \;
        find /media/SANSA/PODCASTS/ -type f -name '*Apache_Tears*' -exec rm -v {} \;

        origdir=`pwd`

        if test -d /home/avar/Podcasts/Science/Science_Talk; then
            cd /home/avar/Podcasts/Science/Science_Talk
            rename 's/(?<!\.mp3)$/.mp3/' *
        fi

        cd /media/SANSA/PODCASTS/
        rsync \
            -av \
            --progress \
            --exclude='*.log' \
            --exclude='*Apache_Tears*' \
            --exclude='*History*' \
            --exclude='*WNYC*' \
            --exclude='*German*' \
            --exclude='*Ostfront*' \
            --exclude='*Hardcore_History*' \
            --exclude='*Apache*' \
            --exclude='*.pdf' \
            --exclude='*.mp4' \
            --exclude='*Linguistics*' \
            --exclude='*.mp3-*' \
            --exclude='*The_Universe_?_*' \
            --exclude='*The_Universe_??_*' \
            --exclude='*The_Universe_1??_*' \
            --exclude='*Skeptics_Guide_1??_*' \
            --exclude='*Skeptics_Guide_2[023]?_*' \
            --exclude='*Skeptics_Guide_24[01234]_*' \
            --exclude='*Hacking/*' \
            --exclude='*News/*' \
            --exclude='*Wikipedia*' \
            --exclude='*Naked*' \
            --delete \
            /home/avar/Podcasts/ \
            .

        if test -d /home/avar/Podcasts/Science/Science_Talk; then
            cd /home/avar/Podcasts/Science/Science_Talk
             rename 's/\.mp3$//' *
        fi

        cd $origdir
    else
        echo "/media/SANSA/ isn't mounted"
    fi
}

# install Common Lisp packages from the command line
function asdf_install {
    sbcl --eval "(asdf:operate 'asdf:load-op :asdf-install)" --eval "(asdf-install:install :$1)" --eval "(quit)"
}

# good for links that keep dropping your ssh connections
function keepalive {
    [ -z $1 ] && interval=60 || interval=$1
    while true; do
        date
        sleep $interval
    done
}

function cpan_release {
    dzil clean && dzil test && dzil build && cpanm --sudo -v *tar.gz && yes | dzil release && dzil clean
}

function cpan_release_hailo {
    ack -h '^=encoding' -A 9001 lib/Hailo.pm > README.pod
    cpan_release

    git push upstream master
    git push upstream --tags
}

function cpanm_o {
    sudo cpan-outdated | xargs sudo cpanm
}

function test_hailo {
    TEST_MYSQL=1 TEST_POSTGRESQL=1 MYSQL_ROOT_PASSWORD=$(cat ~/.mypass) TEST_EXHAUSTIVE=1 dzil test
}

function hailo_benchmark {
    TEST_POSTGRESQL=1 TEST_MYSQL=1 MYSQL_ROOT_PASSWORD=$(cat ~/.mypass) TEST_EXHAUSTIVE=1 utils/hailo-benchmark-lib-vs-system \
        10 \
        "$(find  t -name '*.t' | egrep -v -e non_stand -e readline -e shell | tr '\n' ' ')"
}


# For perl5 core
function avar_configure         {
    ./Configure -DDEBUGGING=both -Doptimize=-ggdb3 -Dusethreads -Dprefix=~/perl5-rc3/installed -Dusedevel -des
}

# tsocks:
# ssh -D 8088 v

# /etc/tsocks.conf:
# server = 127.0.0.1
# server_port = 8088
# server_type = 5

# . tsocks -on
# firefox

# cpan jfdi is 'prerequisites_policy' => q[follow], in your .cpan/CPAN/MyConfig.pm and PERL_MM_USE_DEFAULT=1 in the environment.
# follow deps is PERL_AUTOINSTALL=--defaultdeps PERL_MM_USE_DEFAULT=1 in the environment and o conf prerequisites_policy follow; o conf commit; in the cpan shell
