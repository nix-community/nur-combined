#!/bin/sh

curl -s https://api.github.com/repos/laurent22/joplin/releases | jq '.[0].tag_name' | cut -d '"' -f 2 | cut -c 2-
