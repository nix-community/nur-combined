# shellcheck shell=bash
# Refresh package pins: data whose URL and hash must change together.
#
# A package declares `passthru.pins`; this runner owns discovery, change detection,
# prefetching and the atomic write, so a package only says how to resolve its identity.
#
# Usage:
#   nix run .#update-pins                 # refresh every package that declares pins
#   nix run .#update-pins -- <name> ...   # only these, re-prefetching unconditionally

if [[ ! -f flake.nix || ! -d pkgs ]]; then
  echo "ERROR: update-pins must be run from the repository root" >&2
  exit 1
fi

sources_file=_sources/generated.json
if [[ ! -f $sources_file ]]; then
  echo "ERROR: $sources_file not found; update-pins must run after update-sources" >&2
  exit 1
fi

# Substitute {dotted.path} references in a URL template from the resolved identity.
expand_template() {
  local template=$1 identity=$2
  local out="" rest=$template ref value

  while [[ $rest == *'{'* ]]; do
    out+="${rest%%\{*}"
    rest="${rest#*\{}"
    if [[ $rest != *'}'* ]]; then
      echo "ERROR: unterminated { in pin URL template: $template" >&2
      return 1
    fi
    ref="${rest%%\}*}"
    rest="${rest#*\}}"

    value=$(jq -r --arg ref "$ref" '
      getpath($ref | split(".")) | select(type == "string")
    ' <<<"$identity")
    if [[ -z $value ]]; then
      echo "ERROR: pin URL template references missing or non-string path {$ref}: $template" >&2
      return 1
    fi
    out+="$value"
  done

  printf '%s\n' "$out$rest"
}

# Write canonical JSON only when the content changed, leaving the worktree alone otherwise.
write_pins() {
  local path=$1 json=$2 new old tmp
  if ! new=$(jq -S . <<<"$json"); then
    echo "ERROR: refusing to write invalid JSON to $path" >&2
    return 1
  fi
  if [[ -f $path ]]; then
    if ! old=$(jq -S . <"$path"); then
      echo "ERROR: existing $path is not valid JSON" >&2
      return 1
    fi
    if [[ $old == "$new" ]]; then
      echo "$path: unchanged"
      return 0
    fi
  fi
  tmp=$(mktemp "$(dirname "$path")/.$(basename "$path").XXXXXX")
  printf '%s\n' "$new" >"$tmp"
  mv "$tmp" "$path"
  echo "$path: updated"
}

update_package_pins() {
  local name=$1 force=$2
  local pins_file="pkgs/$name/pins.json"
  local hashes resolver resolve_bin source_entry identity verdict key url hash resolved

  # Quote the attribute so non-identifier package names resolve.
  hashes=$(nix eval --json ".#legacyPackages.${SYSTEM}.\"$name\".pins.hashes")
  resolver=$(
    nix build --no-link --print-out-paths ".#legacyPackages.${SYSTEM}.\"$name\".pins.resolve"
  )
  # Run the resolver's sole executable.
  resolve_bin=$(find "$resolver/bin" -maxdepth 1 \( -type f -o -type l \) | head -n 1)

  source_entry=$(jq -c --arg name "$name" '.[$name] // empty' "$sources_file")
  if [[ -z $source_entry ]]; then
    echo "ERROR: $name has no source in $sources_file" >&2
    return 1
  fi

  identity=$(PIN_SOURCE="$source_entry" "$resolve_bin")
  if ! jq -e 'type == "object"' >/dev/null <<<"$identity"; then
    echo "ERROR: $name: the pin resolver did not print a JSON object" >&2
    return 1
  fi

  # Unchanged means the identity still matches and every declared hash is already filled in.
  if [[ -f $pins_file && $force -eq 0 ]]; then
    verdict=$(
      jq -rn \
        --slurpfile current "$pins_file" \
        --argjson identity "$identity" \
        --argjson hashes "$hashes" '
        ($current[0]) as $c
        | [$hashes | keys[] | split(".")] as $paths
        | ($paths | all(. as $p | ($c | getpath($p)) | type == "string" and length > 0)) as $filled
        | (reduce $paths[] as $p ($identity; setpath($p; $c | getpath($p)))) as $merged
        | if $filled and ($merged == $c) then "unchanged" else "changed" end
      '
    )
    if [[ $verdict == unchanged ]]; then
      echo "$pins_file: unchanged"
      return 0
    fi
  fi

  resolved=$identity
  while IFS= read -r key; do
    url=$(expand_template "$(jq -r --arg k "$key" '.[$k]' <<<"$hashes")" "$identity")
    echo "$name: prefetching $key from $url"
    if ! hash=$(nix store prefetch-file --json "$url" | jq -r '.hash // empty'); then
      echo "ERROR: $name: nix store prefetch-file failed for $url" >&2
      return 1
    fi
    if [[ -z $hash ]]; then
      echo "ERROR: $name: empty hash for $url" >&2
      return 1
    fi
    resolved=$(jq --arg k "$key" --arg h "$hash" 'setpath($k | split("."); $h)' <<<"$resolved")
  done < <(jq -r 'keys[]' <<<"$hashes")

  write_pins "$pins_file" "$resolved"
}

# Packages exposing passthru.pins, from the unfiltered set so other platforms still update.
# Use getAttr for non-identifier package names and preserve evaluation failures.
mapfile -t all < <(
  nix eval --json ".#legacyPackages.${SYSTEM}" --apply '
    pkgs: builtins.filter
      (n: ((builtins.getAttr n pkgs).pins or null) != null)
      (builtins.attrNames pkgs)
  ' | jq -r '.[]'
)

declare -A known=()
for name in "${all[@]}"; do
  known[$name]=1
done

# Named packages are forced: re-download and re-hash even when the identity is unchanged.
force=0
selected=()
if [[ $# -gt 0 ]]; then
  force=1
  bad=0
  for arg in "$@"; do
    if [[ -n ${known[$arg]:-} ]]; then
      selected+=("$arg")
    else
      echo "WARNING: $arg does not exist or exposes no passthru.pins" >&2
      bad=1
    fi
  done
  if [[ $bad -ne 0 ]]; then
    exit 1
  fi
else
  selected=("${all[@]}")
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "No packages with passthru.pins; nothing to do"
  exit 0
fi

for name in "${selected[@]}"; do
  echo "Updating pins for $name"
  update_package_pins "$name" "$force"
done
