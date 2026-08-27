# shellcheck shell=bash
# Resolve BakaMusic's LibreMPEG and koffi pin identity from its upstream tag.
# Reads the nvfetcher source entry from PIN_SOURCE and prints the identity as JSON;
# update-pins owns change detection, prefetching and writing pins.json.

tag=$(jq -r '.version // empty' <<<"$PIN_SOURCE")
if [[ ! $tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: unexpected bakamusic tag in PIN_SOURCE: '$tag'" >&2
  exit 1
fi
echo "bakamusic upstream tag: $tag" >&2

# Read the LibreMPEG pin and runtime metadata from the tagged manifest.

manifest_url="https://raw.githubusercontent.com/Zencok/BakaMusic/${tag}/scripts/media-runtime-manifest.json"
if ! manifest=$(curl -fsSL --retry 3 "$manifest_url"); then
  echo "ERROR: could not fetch $manifest_url" >&2
  exit 1
fi

mpv_version=$(jq -r '.mpv.version // empty' <<<"$manifest")
engine=$(jq -r '.mpv.engine // empty' <<<"$manifest")
backend=$(jq -r '.mpv.mediaBackend // empty' <<<"$manifest")
decoders_json=$(jq -c '.mpv.decoders // empty' <<<"$manifest")
librempeg_commit=$(jq -r '.mpv.sourceCommits.librempeg // empty' <<<"$manifest")

if [[ -z $mpv_version || -z $decoders_json ]]; then
  echo "ERROR: $manifest_url lacks mpv.version/decoders" >&2
  exit 1
fi
if [[ $engine != "libmpv" || $backend != "librempeg" ]]; then
  echo "ERROR: upstream media runtime changed engine/backend to $engine/$backend; review the packaging" >&2
  exit 1
fi
if [[ -z $(jq -r 'index("ac4") // empty' <<<"$decoders_json") ]]; then
  echo "ERROR: upstream media runtime no longer declares the ac4 decoder" >&2
  exit 1
fi
if [[ ! $librempeg_commit =~ ^[0-9a-f]{40}$ ]]; then
  echo "ERROR: invalid librempeg source commit in manifest: '$librempeg_commit'" >&2
  exit 1
fi

# Map the tagged npm koffi version to its rygel source tag.

lock_url="https://raw.githubusercontent.com/Zencok/BakaMusic/${tag}/package-lock.json"
if ! lockfile=$(curl -fsSL --retry 3 "$lock_url"); then
  echo "ERROR: could not fetch $lock_url" >&2
  exit 1
fi
koffi_version=$(jq -r '.packages["node_modules/koffi"].version // empty' <<<"$lockfile")
if [[ ! $koffi_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: no koffi version in $lock_url" >&2
  exit 1
fi

koffi_ref="koffi/${koffi_version}"
koffi_ref_encoded=$(jq -rn --arg ref "$koffi_ref" '$ref | @uri')
commit_url="https://codeberg.org/api/v1/repos/Koromix/rygel/git/commits/${koffi_ref_encoded}"
if ! commit_json=$(curl -fsSL --retry 3 "$commit_url"); then
  echo "ERROR: rygel has no resolvable ref '$koffi_ref' for koffi $koffi_version." >&2
  echo "Find the matching commit at https://codeberg.org/Koromix/rygel and pin it manually in pkgs/bakamusic/pins.json." >&2
  exit 1
fi
koffi_commit=$(jq -r '.sha // empty' <<<"$commit_json")
if [[ ! $koffi_commit =~ ^[0-9a-f]{40}$ ]]; then
  echo "ERROR: could not resolve rygel ref '$koffi_ref' to a commit" >&2
  exit 1
fi

# Verify the source tag matches the lockfile version.
koffi_pkg_url="https://codeberg.org/Koromix/rygel/raw/tag/${koffi_ref_encoded}/src/koffi/package.json"
koffi_pkg_version=$(curl -fsSL --retry 3 "$koffi_pkg_url" | jq -r '.version // empty')
if [[ $koffi_pkg_version != "$koffi_version" ]]; then
  echo "ERROR: rygel ref '$koffi_ref' contains koffi $koffi_pkg_version, expected $koffi_version; pin the commit manually" >&2
  exit 1
fi

jq -n \
  --arg mpv_version "$mpv_version" \
  --arg engine "$engine" \
  --arg backend "$backend" \
  --argjson decoders "$decoders_json" \
  --arg librempeg_commit "$librempeg_commit" \
  --arg koffi_version "$koffi_version" \
  --arg koffi_commit "$koffi_commit" \
  '{
    koffi: {
      version: $koffi_version,
      commit: $koffi_commit
    },
    mpvRuntime: {
      version: $mpv_version,
      engine: $engine,
      mediaBackend: $backend,
      decoders: $decoders,
      librempeg: {
        commit: $librempeg_commit
      }
    }
  }'
