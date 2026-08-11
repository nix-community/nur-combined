dependencies

$ grep -h -o -E ' \| [a-z]+' result/bin/* | cut -c4- | sort -u | grep -v eval | xargs which | xargs readlink -f | cut -d/ -f4 | cut -c34- | sort -u | sed 's/-[0-9].*$//'
bc
coreutils-full
gawk
gnugrep
gnused
imagemagick
