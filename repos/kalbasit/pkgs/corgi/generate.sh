#!/usr/bin/env nix-shell
#! nix-shell -i bash -p go2nix go git

set -euo pipefail

if [[ "${#}" -ne "1" ]]; then
    echo -e "USAGE: $0 <ref>"
fi

readonly rev="${1}"
readonly here="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
export GOPATH="$(mktemp -d)"

function cleanup() {
    rm -rf "${GOPATH}"
}
trap cleanup EXIT INT QUIT TERM

mkdir -p "${GOPATH}/src/github.com/DrakeW"
cd "${GOPATH}/src/github.com/DrakeW"
git clone https://github.com/DrakeW/corgi.git
cd corgi
git checkout "${rev}"
go get ./...

cd "${GOPATH}/src/github.com/DrakeW/corgi"

go2nix save -o "${here}/default.nix" -d "${here}/deps.nix"
