#!/bin/bash

set -euxo pipefail

version=$1

function get_hash() {
	nix hash to-sri --type sha256 $(nix-prefetch-url https://github.com/dagger/dagger/releases/download/v${version}/dagger_v${version}_${1}.tar.gz)
}

cat <<EOF
  shaMap = {
    x86_64-linux = "$(get_hash linux_amd64)";
    aarch64-linux = "$(get_hash linux_arm64)";
    x86_64-darwin = "$(get_hash darwin_amd64)";
    aarch64-darwin = "$(get_hash darwin_arm64)";
  };

  urlMap = {
    x86_64-linux = "https://dl.dagger.io/dagger/releases/${version}/dagger_v${version}_linux_amd64.tar.gz";
    aarch64-linux = "https://dl.dagger.io/dagger/releases/${version}/dagger_v${version}_linux_arm64.tar.gz";
    x86_64-darwin = "https://dl.dagger.io/dagger/releases/${version}/dagger_v${version}_darwin_amd64.tar.gz";
    aarch64-darwin = "https://dl.dagger.io/dagger/releases/${version}/dagger_v${version}_darwin_arm64.tar.gz";
  };
EOF
