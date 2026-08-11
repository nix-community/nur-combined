# wsrx-desktop pin updater (exposed as passthru.pinUpdater, driven by the
# generic `nix run .#update-pins` runner). Regenerates pins.json — the
# rust-skia prebuilt asset pin — from the committed, crate2nix-generated
# Cargo.nix. Must run from the repository root; only ever writes
# pkgs/wsrx-desktop/pins.json. `--force` re-prefetches the assets even
# when the pin identity is unchanged (upstream asset drift, fetcher
# behavior changes).

# PIN_UTILS is injected by the Nix wrapper (runtimeEnv); it points at
# scripts/package-updates/lib/pin-utils.sh.
# shellcheck source=/dev/null
source "$PIN_UTILS"

force=0
if [[ ${1:-} == "--force" ]]; then
  force=1
fi

cargo_nix=pkgs/wsrx-desktop/Cargo.nix
pins_file=pkgs/wsrx-desktop/pins.json

if [[ ! -f $cargo_nix ]]; then
  echo "ERROR: $cargo_nix not found; update-pins must run from the repository root after update-lockfiles" >&2
  exit 1
fi

version=$(pin_crate_version "$cargo_nix" skia-bindings)
features=$(pin_crate_resolved_features "$cargo_nix" skia-bindings)
echo "skia-bindings $version, resolved features: $features"

# rust-skia release asset feature keys, in the fixed order upstream uses
# in its binary file names. A resolved feature that is not in this table
# must be added to ignored_features below after checking upstream naming —
# never guessed, because a wrong key silently produces a 404 or, worse, a
# valid URL to the wrong binaries.
declare -A feature_keys=(
  [gl]=gl
  [jpeg-decode]=jpegd
  [jpeg-encode]=jpege
  [pdf]=pdf
  [svg]=svg
  [textlayout]=textlayout
  [vulkan]=vulkan
  [webp-decode]=webpd
  [webp-encode]=webpe
)
key_order=(gl jpeg-decode jpeg-encode pdf svg textlayout vulkan webp-decode webp-encode)

# Resolved features that never appear in Linux asset keys: build-time
# behavior (binary-cache, embed-icudtl), pure aliases (jpeg = jpeg-encode
# + jpeg-decode, webp likewise) and non-Linux GPU backends (d3d, metal).
ignored_features=(binary-cache embed-icudtl jpeg webp d3d metal)

declare -A unhandled=()
for f in $features; do
  unhandled[$f]=1
done

parts=()
for f in "${key_order[@]}"; do
  if [[ -n ${unhandled[$f]:-} ]]; then
    parts+=("${feature_keys[$f]}")
    unset "unhandled[$f]"
  fi
done
for f in "${ignored_features[@]}"; do
  unset "unhandled[$f]"
done
if ((${#unhandled[@]} > 0)); then
  echo "ERROR: skia-bindings $version resolves unknown feature(s): ${!unhandled[*]}" >&2
  echo "Map them to a rust-skia asset feature key or add them to ignored_features after checking upstream naming." >&2
  exit 1
fi
if ((${#parts[@]} == 0)); then
  echo "ERROR: no Linux asset features resolved for skia-bindings $version" >&2
  exit 1
fi
feature_key=$(
  IFS=-
  echo "${parts[*]}"
)

assets=$(pin_gh_release_assets rust-skia/skia-binaries "$version")

# Each architecture must yield exactly one asset, and the Skia commit
# embedded in both file names must agree (a release mixing commits would
# mean the two tarballs are not the same Skia build).
declare -A asset_url=()
declare -A commits=()
for target in x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu; do
  match=$(pin_match_asset "^skia-binaries-[0-9a-f]+-${target}-${feature_key}\.tar\.gz"$'\t' <<<"$assets")
  name=${match%%$'\t'*}
  asset_url[$target]=${match#*$'\t'}
  commit=${name#skia-binaries-}
  commit=${commit%%-*}
  commits[$commit]=1
done
if ((${#commits[@]} != 1)); then
  echo "ERROR: Skia commit mismatch across architectures: ${!commits[*]}" >&2
  exit 1
fi
commit=${!commits[*]}

# Identity check: skip the (expensive) prefetch when the pin already
# describes exactly these assets, unless a refresh was forced.
if [[ -f $pins_file ]]; then
  cur_version=$(jq -r '.skia.version // empty' "$pins_file")
  cur_commit=$(jq -r '.skia.commit // empty' "$pins_file")
  cur_features=$(jq -r '.skia.features // empty' "$pins_file")
  cur_hash_x86=$(jq -r '.skia.hashes["x86_64-linux"] // empty' "$pins_file")
  cur_hash_arm=$(jq -r '.skia.hashes["aarch64-linux"] // empty' "$pins_file")
  if [[ -z $cur_version || -z $cur_commit || -z $cur_features ]]; then
    echo "ERROR: $pins_file exists but lacks skia.version/commit/features" >&2
    exit 1
  fi
  if [[ $force -eq 0 &&
    $cur_version == "$version" &&
    $cur_commit == "$commit" &&
    $cur_features == "$feature_key" &&
    -n $cur_hash_x86 && -n $cur_hash_arm ]]; then
    echo "wsrx-desktop: skia pin unchanged ($version, $commit, $feature_key)"
    exit 0
  fi
fi

echo "wsrx-desktop: prefetching skia $version ($commit, $feature_key)"
hash_x86=$(pin_prefetch_sri "${asset_url[x86_64-unknown-linux-gnu]}")
hash_arm=$(pin_prefetch_sri "${asset_url[aarch64-unknown-linux-gnu]}")

new_json=$(jq -n \
  --arg version "$version" \
  --arg commit "$commit" \
  --arg features "$feature_key" \
  --arg hash_x86 "$hash_x86" \
  --arg hash_arm "$hash_arm" \
  '{
    skia: {
      version: $version,
      commit: $commit,
      features: $features,
      hashes: {
        "x86_64-linux": $hash_x86,
        "aarch64-linux": $hash_arm
      }
    }
  }')

pin_write_json "$pins_file" "$new_json"
