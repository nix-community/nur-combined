#!/usr/bin/env bash
# univ: update niv (and generate a nice commit)

set -euo pipefail

SOURCES=nix/sources.json

error() {
    echo "::error::$*"
    exit 1
}

update() {
    local dep=$1
    echo "checking for update: $dep" >&2
    owner=$(jq -r ".\"$dep\".owner" < ${SOURCES})
    repo=$(jq -r ".\"$dep\".repo" < ${SOURCES})
    old_rev=$(jq -r ".\"$dep\".rev" < ${SOURCES})
    dep_url=$(jq -r ".\"$dep\".url // empty" < "${SOURCES}" | { grep github.com || true; })
    [[ -n $dep_url ]] && is_github="yes" || is_github=""
    niv update $dep 1>&2
    new_rev=$(jq -r ".\"$dep\".rev" < ${SOURCES})
    if [[ $old_rev == $new_rev ]]; then
        echo "… no updates" >&2
        return
    fi
    echo "$dep: ${old_rev} to ${new_rev}"
    if [[ -z $is_github ]]; then
        echo "$dep not using github.com, no changelog"
    else
        merges_filter=""
        hub api "/repos/$owner/$repo/compare/${old_rev}...${new_rev}" \
            | jq -r '.commits[] '"$merges_filter"' | "* [`\(.sha[0:8])`](\(.html_url)) \(.commit.message | split("\n") | first)"' \
            | sed "s~\(#[0-9]\+\)~$owner/$repo\1~g"
    fi
}

main() {
    message=$(mktemp)
    commit_msg=$(mktemp)
    for dep in $(jq -r 'keys[]' < ${SOURCES}); do
        update $dep >> $message
        echo "" >> $message
    done
    echo $message $commit_msg
    content=$(cat $message | tr -d '\n')
    if [[ -z "$content" ]]; then
        echo "No updates, do nothing"
        exit 0
    fi
    echo "nix: niv update(s)" > $commit_msg
    echo "" >> $commit_msg
    cat $message >> $commit_msg
    git add nix
    git commit -F $commit_msg
}

main $@
