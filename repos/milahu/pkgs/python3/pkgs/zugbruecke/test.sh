#!/usr/bin/env bash

set -e

wenv=
zugbruecke=

if false; then
# read cache for writable-nix-store
wenv=/nix/store/...
zugbruecke=/nix/store/...

wenv=/nix/store/8nqnhn7gqy02bfl0nglgck9m2s96lj9y-wenv-0.5.1
zugbruecke=/nix/store/3q5wxjb594bb2z1523in9fparvxsxvcp-zugbruecke-0.2.1

wenv=/nix/store/24092lxsyyfd0yknj230x9mhpqn8mpqp-wenv-0.5.1
zugbruecke=/nix/store/20jpilh4vmg7d6k7si95ms0y5iwdnr1p-zugbruecke-0.2.1
fi

if [ -z "$wenv" ]; then wenv=$(nix-build . -A python3.pkgs.wenv); fi
if [ -z "$zugbruecke" ]; then zugbruecke=$(nix-build . -A python3.pkgs.zugbruecke); fi

echo
echo "wenv=$wenv"
echo "zugbruecke=$zugbruecke"
echo

#for arch in win32 win64; do
for arch in win64; do

echo "testing arch=$arch"

PYTHONPATH=$wenv/lib/python3.11/site-packages:$zugbruecke/lib/python3.11/site-packages \
WENV_ARCH=$arch \
python -c "$(
cat <<EOF
import os
#os.environ["WENV_PREFIX"] = os.environ["HOME"] + "/.cache/wenv"
import zugbruecke.ctypes as ctypes
dll_pow = ctypes.cdll.msvcrt.pow
dll_pow.argtypes = (ctypes.c_double, ctypes.c_double)
dll_pow.restype = ctypes.c_double
print(f'You should expect "1024.0" to show up here: "{dll_pow(2.0, 10.0):.1f}".')

EOF
)"

done

# check "install on runtime" files
# TODO these should be installed on build time
# so it works offline

set -x

ls  $HOME/.cache/wenv/share/wenv/win32/drive_c/python-*/Lib/site-packages
