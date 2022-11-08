#!/bin/sh

set -ex

oxipng -o 4 --strip safe -Z $1 --out $2
[ "$(wc -c $2 | awk '{print $1}')" -le $3 ] && exit 0

for i in $(seq 100 -1 0); do
  cat $1 | pngquant --quality 0-$i - | oxipng -o 4 --strip safe -Z - --out $2
  [ "$(wc -c $2 | awk '{print $1}')" -le $3 ] && exit 0
done

rm $2
exit 1
