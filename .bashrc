export PATH=$PATH:$HOME/g/misc-scripts:$HOME/g/rtmpdump:$HOME/src/dl/rakudo-star-2010.07/install/bin
test -f ~/perl5/perlbrew/etc/bashrc && source ~/perl5/perlbrew/etc/bashrc
test -f ~v-perlbrew/perl5/perlbrew/etc/bashrc && source ~v-perlbrew/perl5/perlbrew/etc/bashrc

cpus=$(grep -c ^processor /proc/cpuinfo)
export HARNESS_OPTIONS="j$((2*$cpus+1))"

if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# away with old aliases
\unalias -a

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


# Unfail Ubuntu 10.04
if type gconftool-2 >/dev/null 2>&1 && test -n "$DISPLAY"
then
    gconftool-2 --set /apps/metacity/general/button_layout --type string menu:minimize,maximize,close >/dev/null
fi

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

# Colors on a per-server basis based on a simple
# checksum. Inspired by http://geofft.mit.edu/blog/sipb/125
function hostname_color() {
    echo $((31 + $(hostname | cksum | cut -c1-3) % 6))
    return 0
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
        PS1='\[\e[1;$(hostname_color)m\]\h\[\e[m\] \[\e[1;34m\]\W\[\e[m\] (\[\e[;33m\]$(dir_info)\[\e[m\]) \[\e[1;31m\]\$\[\e[m\] '
    else
        PS1='\[\e[1;$(hostname_color)m\]\h\[\e[m\] \[\e[1;34m\]\W\[\e[m\] (\[\e[;33m\]$(dir_info)\[\e[m\]) \[\e[1;32m\]\$\[\e[m\] '
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

# Include alias x=y statements
. ~/.aliases

if [[ "$TERM" == "linux" ]]; then
    if type conpalette >&/dev/null; then
        conpalette tango-dark
    fi
fi

# GNU it
export EDITOR="emacsclient"

# So ack(1) will use unicode, this probably fixes other stuff too that
# didn't heed my locale
#export PERL_UNICODE=SDAL

# some nice less(1) options
export LESS="--IGNORE-CASE --LONG-PROMPT --QUIET --chop-long-lines --RAW-CONTROL-CHARS"

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

    git push origin master
    git push origin --tags

    git push upstream master
    git push upstream --tags
}

function cpanm_o {
    sudo cpan-outdated | xargs cpanm -S
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
function avar_configure {
    ./Configure -DDEBUGGING=both -Doptimize=-ggdb3 -Dusethreads -Dprefix=~/perl5/installed -Dusedevel -des
}

function avar_configure_nodebug {
    ./Configure -Dusethreads -Dprefix=~/perl5/installed -Dusedevel -des
}

# For MediaWiki
mw_services="apache2 mysql memcached tomcat6"
function start_mw {
    for service in $mw_services; do
        sudo service $service restart
    done
}

function mw_stop {
    for service in $mw_services; do
        sudo service $service stop
    done
}

function bootstrap_cpanm {
    curl -L http://cpanmin.us | perl - App::cpanminus
}

function use_icelandic {
    # Use Icelandic
    unset LANGUAGE
    export LANG=is_IS.UTF-8
}

function nuke_git {
    sudo find /usr/local/libexec/ -name '*git*' -exec rm -rfv {} \;
    sudo find /usr/local/share/ -name '*git*' -exec rm -rfv {} \;
    sudo find /usr/local/bin/ -name '*git*' -exec rm -rfv {} \;
    sudo find /usr/local/share/perl/ -name '*Git*' -exec rm -rfv {} \;
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
