#!/bin/sh
set -eu
cd "$(dirname "$0")"
project_root=$(cd ../../.. && pwd)
cargo build --manifest-path Cargo.toml --release --locked --offline \
    --target wasm32-unknown-unknown --target-dir "$project_root/target/wasm-plugins"
install -m 644 "$project_root/target/wasm-plugins/wasm32-unknown-unknown/release/spotlight_wasm_text_tools.wasm" plugin.wasm
printf '%s\n' 'Built examples/plugins/text-tools/plugin.wasm'
