## Variables I use in the rest of ~/.bashrc.d and ~/.aliases.d
export NPROC=$(nproc)

## Concurrency
# go(1)
export GOMAXPROCS=$NPROC
# make(1)
export MAKEFLAGS=j$NPROC
# prove(1)
export HARNESS_OPTIONS=j$NPROC

