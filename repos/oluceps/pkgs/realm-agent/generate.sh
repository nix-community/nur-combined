#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${BPF_CLANG:=clang}"
"$BPF_CLANG" -target bpfel -O2 -g -Wall -Werror "$@" -c bpf/realm.bpf.c -o bpf/realm_bpf.o
