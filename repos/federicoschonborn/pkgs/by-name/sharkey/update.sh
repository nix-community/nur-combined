#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-update

version=$(curl "https://activitypub.software/api/v4/projects/TransFem-org%2FSharkey/repository/tags" | jq -r '.[0].release.tag_name')
nix-update sharkey --version "$version"
