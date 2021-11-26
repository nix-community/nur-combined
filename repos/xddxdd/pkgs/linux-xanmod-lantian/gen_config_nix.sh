#!/bin/sh

echo "{" > "config.nix"
while IFS='=' read key val; do
    [ "x${key#CONFIG_}" != "x$key" ] || continue
    no_firstquote="${val#\"}";
    echo '  "'"$key"'" = "'"${no_firstquote%\"}"'";' >> "config.nix"
done < "config"
echo "}" >> config.nix
