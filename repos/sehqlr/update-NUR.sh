#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl

curl -XPOST https://nur-update.herokuapp.com/update?repo=sehqlr
