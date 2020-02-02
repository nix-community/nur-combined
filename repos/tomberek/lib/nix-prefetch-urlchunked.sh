#!/usr/bin/env nix-shell
#! nix-shell -p parallel curl coreutils
#! nix-shell -i bash

# $1 is the url of the file to fetch
# $2 is optionsl chunk size, defaults to 32 MiB
set -Eeou pipefail
url="$1"
export chunk="${2:-$(( 1024 * 1024 * 32 ))}"

echo Testing server ability to split
size="$(curl -r 0-0 --fail --silent "$url")"
echo Getting size
file_size=$(curl --head --fail --silent "$url" | awk '/length/ {gsub("\\r","");printf "%s",$2}' )

export chunks=$(( (file_size + chunk - 1)/chunk ))

echo "splitting $url"
echo "size ($file_size) in chunks of ($chunk)"

parallel --keep-order curl "$url" --fail --silent -r{}-'$(( {} + $chunk - 1))' \
    \| sha256sum  ::: $(seq 0 $chunk $file_size) | awk '{print "\"" $1 "\""}'
