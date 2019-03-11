source $stdenv/setup

tar xvfz $src
cd ocaml-*
./configure --prefix $out
make world
umask 022       # make sure to give read & execute permission to all
make install