function cpan_release {
    dzil clean && RELEASE_TESTING=1 dzil test && dzil build && cpanm --sudo -v *tar.gz && dzil release && dzil clean
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

function bootstrap_cpanm {
    curl -L http://cpanmin.us | perl - App::cpanminus
}
