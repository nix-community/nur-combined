#!/bin/sh

URL=$(curl -s https://api.github.com/repos/laurent22/joplin/releases | jq -r '.[0].assets[].browser_download_url'|grep '.*AppImage$')

echo $URL
nix-prefetch-url $URL
