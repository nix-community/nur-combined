#! /usr/bin/env bash

echo TODO implement update
exit 1

filesHtml="$(curl -s "https://files.radicle.xyz/?sort=time&order=asc")"

# https://github.com/radicle-dev/heartwood/commit/594381d051b06a87dc9f517e99cc0d524274c6a9
#versionCommit = "594381d051b06a87dc9f517e99cc0d524274c6a9";
versionCommit=$(echo "$filesHtml" | grep -F '<a href="./' | head -n1 | cut -d'"' -f2 | cut -c3-42)

#versionDate = "2023-04-07";
versionDate=$(echo "$filesHtml" | grep -F '...TODO...')

nix-prefetch-url https://files.radicle.xyz/594381d051b06a87dc9f517e99cc0d524274c6a9/aarch64-unknown-linux-musl/radicle-aarch64-unknown-linux-musl.tar.gz
sha256sum /nix/store/snnk1j4xrnlyhn76pq8am467wsv6qg1l-radicle-aarch64-unknown-linux-musl.tar.gz
echo -n sha256-; echo -n 8cb0a0abaa26382349d6ee69936daaa510b955b3cf7ca47f64b0c84ce9a05374 | xxd -p -r | base64 -w0

# version is printed by: radicle-node --help # TODO better?
#version = "0.2.0-unstable-${versionDate}";

# https://discourse.nixos.org/t/what-are-the-possible-values-of-stdenv-hostplatform-system/5594/4
# nix-repl> lib.platforms.all
# [ "aarch64-linux" "armv5tel-linux" "armv6l-linux" "armv7a-linux" "armv7l-linux" "mipsel-linux" "i686-cygwin" "i686-freebsd" "i686-linux" "i686-netbsd" "i686-openbsd" "x86_64-cygwin" "x86_64-freebsd" "x86_64-linux" "x86_64-netbsd" "x86_64-openbsd" "x86_64-solaris" "x86_64-darwin" "i686-darwin" "aarch64-darwin" "armv7a-darwin" "x86_64-windows" "i686-windows" "wasm64-wasi" "wasm32-wasi" "powerpc64le-linux" "riscv32-linux" "riscv64-linux" "aarch64-none" "avr-none" "arm-none" "i686-none" "x86_64-none" "powerpc-none" "msp430-none" "riscv64-none" "riscv32-none" "vc4-none" "js-ghcjs" ]
