#! /usr/bin/env bash

versions=$(grep -P '^  "\d+.\d+.\d+" = {' versions.nix | cut -d'"' -f2)

if [ -n "$@" ]; then
  versions="$@"
fi

for version in $versions
do

echo v = $version

IFS=. read a b c <<<"$version"

echo a = $a; echo b = $b; echo c = $c

#u=https://s3.amazonaws.com/kindleforpc/$c/KindleForPC-installer-$version.exe
u=https://kindleforpc.s3.amazonaws.com/$c/KindleForPC-installer-$version.exe

echo u = $u

curl -I $u

done
