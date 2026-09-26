#!/usr/bin/env bash
# Normalize CSS for cross-compiler equivalence comparison.
# Reads CSS on stdin, writes normalized CSS on stdout.
#
# Normalizations (whitespace-only; we do NOT alter values, so genuine semantic
# divergences still show up as diffs):
#   - collapse runs of whitespace to a single space
#   - put a newline after every } and ; so diffs are line-oriented
#   - trim leading/trailing whitespace on each line
#   - drop blank lines
# This is deliberately conservative: it only forgives formatting differences,
# not differences in selectors, properties, or computed color/number values.
set -euo pipefail

# Use awk/tr/sed only for whitespace; never touch the tokens themselves.
tr '\n\t' '  ' \
  | sed -E 's/  +/ /g; s/ *([{};,]) */\1/g; s/}/}\n/g; s/;/;\n/g; s/{/{\n/g' \
  | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
  | grep -v '^[[:space:]]*$' || true
