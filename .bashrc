## Include system-wide bashrc

if test -f /etc/bashrc
then
    . /etc/bashrc
fi

## set my PATH

maybe_add_path() {
    if test -d $1
    then
        PATH=$1:$PATH
    fi
}

# custom scripts
maybe_add_path $HOME/g/misc-scripts
maybe_add_path $HOME/.ssh/bin

# ruby
maybe_add_path /var/lib/gems/1.8/bin

# custom git builds
maybe_add_path /opt/git/pu/bin
maybe_add_path /opt/git/ab-i18n/bin

# Macports
maybe_add_path /opt/local/bin
maybe_add_path /opt/local/sbin

# git on Mac OS X
maybe_add_path /usr/local/git/bin

# Custom binaries
maybe_add_path $HOME/local/bin

# perlbrew
test -f ~/perl5/perlbrew/etc/bashrc && source ~/perl5/perlbrew/etc/bashrc
test -f ~v-perlbrew/perl5/perlbrew/etc/bashrc && HOME=/home/v-perlbrew source ~v-perlbrew/perl5/perlbrew/etc/bashrc

# custom blead compile
maybe_add_path ~/perl5/installed/bin

if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# away with old aliases
\unalias -a

# bash completion
if test -f /dev/shm/bash_dyncompletion
then
    # Lightspeed from Debian bug
    # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=467231
    . /dev/shm/bash_dyncompletion
elif test -f /etc/bash_completion
then
    . /etc/bash_completion
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


# Adjust GTK settings under X/Ubuntu/GTK+
if test -n "$DISPLAY" &&
    type gconftool-2 >/dev/null 2>&1
then
    {
        # Re-arrange the buttons on Ubuntu to be less confusing.
        gconftool-2 --type string \
            --set /apps/metacity/general/button_layout \
            menu:minimize,maximize,close

        # Use Emacs keybindings in GTK
        gconftool --type string \
            --set /desktop/gnome/interface/gtk_key_theme \
            Emacs
    } >/dev/null
fi

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

if [[ "$TERM" == "linux" ]]; then
    if type conpalette >&/dev/null; then
        conpalette tango-dark
    fi
fi

# GNU it
export EDITOR="emacsclient --alternate-editor emacs"

# Our ancient Red Hat boxes at work don't have the CA GitHub uses
export GIT_SSL_NO_VERIFY=1

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

# Use a sensible -j for Test::Harness
case $HOSTNAME in
    v)    __cpus=4 ;;
    aeou) __cpus=2 ;;
    *)    __cpus=$(grep -c ^processor /proc/cpuinfo 2>/dev/null) ;;
esac
export HARNESS_OPTIONS="j$((2*$__cpus+1))"

# Git will screw this up when I do a "git pull"
chmod 600 ~/.ssh/config 2>/dev/null

# OpenBSD settings
if test "$(uname -s)" = "OpenBSD"
then
    export PKG_PATH=http://openbsd.informatik.uni-erlangen.de/pub/OpenBSD/4.7/packages/$(machine -a)
fi

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
    ./Configure -DDEBUGGING=both -Doptimize=-ggdb3 -Dusethreads -Dprefix=$HOME/perl5/installed -Dusedevel -des
}

# for maint-5.6
function avar_configure_56 {
    ./Configure -DDEBUGGING=both -Doptimize=-ggdb3 -Dusethreads -Dprefix=$HOME/perl5/installed -Dusedevel -des &&
    rm -rf ext/IPC/SysV &&
    make -j 6 &&
    make install.perl
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

# debian upgrade
function dug {
    sudo aptitude update
    sudo aptitude upgrade
    sudo aptitude dist-upgrade
}

dotfiles=$HOME/g/avar-dotfiles-work

function bootstrap_work_dotfiles_symlinks {
    cd $dotfiles

    # Set up the symlinks
    for file in $(find $dotfiles -type f | grep -v /\.git)
    do
        ln -sfv $file $(echo $file | sed "s,^$dotfiles,$HOME,")
    done
}

function bootstrap_work_dotfiles {
    if ! test -d $dotfiles
    then
        mkdir -p $dotfiles

        # Bootstap the repository
        (
            git init $dotfiles
            cd $dotfiles
            git config remote.origin.url ssh://git.booking.com/gitroot/users.git
            git config remote.origin.fetch '+refs/heads/avar-dotfiles:refs/remotes/origin/avar-dotfiles'
            git config branch.avar-dotfiles.remote origin
            git config branch.avar-dotfiles.merge refs/heads/avar-dotfiles
            git fetch origin
            git checkout -t origin/avar-dotfiles
        )

        bootstrap_work_dotfiles_symlinks
    fi
}

function dud {
    (
        cd ~/
        git pull
        cd $dotfiles
        git pull
        bootstrap_work_dotfiles_symlinks
    )
}

case "$(hostname -f)" in
    *.booking.com)
        bootstrap_work_dotfiles
        ;;
esac

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
