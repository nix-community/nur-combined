#! /usr/bin/env bash

# turbobench_all.sh
# run turbobench with all codecs
# example use:
# turbobench_all.sh testfile.tar -v2

turbobench=$(which turbobench)

# define default levels
declare -A default_level
# use highest level by default
# turbobench -l1 | tail -n+3 | while read a b; do [ -z "$b" ] && continue; L=${b%%/*}; L=${L##*,}; echo "default_level[$a]=$L # $b"; done
default_level[brotli]=11 # 0,1,2,3,4,5,6,7,8,9,10,11/d#:V
default_level[fastlz]=2 # 1,2
default_level[flzma2]=11 # 0,1,2,3,4,5,6,7,8,9,10,11/mt#
default_level[bsc]=8 # 0,3,4,5,6,7,8/p:e#
default_level[bscqlfc]=2 # 1,2
default_level[libdeflate]=12 # 1,2,3,4,5,6,7,8,9,12/dg
default_level[zpaq]=5 # 0,1,2,3,4,5
default_level[lz4]=16 # 0,1,9,10,11,12,16/MfsB#
default_level[lzham]=4 # 1,2,3,4/t#:fb#:x#
default_level[lzlib]=9 # 1,2,3,4,5,6,7,8,9/d#:fb#
default_level[lzma]=9 # 0,1,2,3,4,5,6,7,8,9/d#:fb#:lp#:lc#:pb#:a#:mt#
default_level[lzo1b]=999 # 1,9,99,999
default_level[lzo1c]=999 # 1,9,99,999
default_level[lzo1f]=999 # 1,999
default_level[lzo1x]=999 # 1,11,12,15,999
default_level[lzo1y]=999 # 1,999
default_level[lzo1z]=999 # 999
default_level[lzo2a]=999 # 999
default_level[lzsa]=9 # 9/f#cr
default_level[quicklz]=3 # 1,2,3
default_level[zlib]=9 # 1,2,3,4,5,6,7,8,9
default_level[zstd]=-22 # 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16,-17,-18,-19,-20,-21,-22/d#
default_level[oodle]=139 # 01,02,03,04,05,06,07,08,09,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,41,42,43,44,45,46,47,48,49,51,52,53,54,55,56,57,58,59,61,62,63,64,65,66,67,68,69,71,72,73,74,75,76,77,78,79,81,82,83,84,85,86,87,88,89,-81,-82,-83,91,92,93,94,95,96,97,98,99,-91,-92,-93,101,102,103,104,105,106,107,108,109,111,112,113,114,115,116,117,118,119,-111,-112,-113,121,122,123,124,125,126,127,128,129,131,132,133,134,135,136,137,138,139
default_level[TurboRC]=90 # 1,2,3,4,9,10,12,14,17,20,21,90/e#
default_level[zlibh]=32 # 8,9,10,11,12,13,14,15,16,32
default_level[srle]=64 # 0,8,16,32,64
default_level[st]=8 # 3,4,5,6,7,8

# get all codecs
e=$($turbobench -l1 | tail -n+3 | awk '{ print $1 }')

# add default levels
for codec in ${!default_level[@]}
do
  level=${default_level[$codec]}
  e=$(echo "$e" | sed "s/^$codec\$/&,$level/")
done

# format
e=$(echo "$e" | xargs printf "%s/")
e=${e:0: -1}

set -x
exec $turbobench -e$e "$@"
