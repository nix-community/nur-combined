{
  pname,
  nyxKey,
  versionPath,
  hasCargo ? false,
  hasSubmodules ? false,
  withLastModifiedDate ? false,
  withLastModified ? false,
  withBump ? false,
  withExtraCommands ? "",
  gitUrl,
  fetchLatestRev,
  writeShellScriptBin,
  lib,
  nix,
  coreutils,
  curl,
  jq,
  git,
}:

let
  baseUrl = lib.removeSuffix ".git" gitUrl;
  path = builtins.concatStringsSep ":" [
    "${nix}/bin"
    "${coreutils}/bin"
    "${curl}/bin"
    "${jq}/bin"
    "${git}/bin"
  ];
in
writeShellScriptBin "update-${pname}-git" ''
  set -euo pipefail

  export PATH=${path}
  VERSION_JSON="''${VERSION_JSON:-${versionPath}}"

  latest_rev=$(${fetchLatestRev})
  current_rev=$(jq -r .rev "$VERSION_JSON")
  current_short=$(printf %s "$current_rev" | cut -c1-7)

  if [ "$latest_rev" = "$current_rev" ]; then
    exit 0
  fi

  base_url="${baseUrl}"
  archive_url="''${base_url}/archive/$latest_rev.tar.gz"

  archive_sha256=$(nix-prefetch-url --unpack --type sha256 "$archive_url")
  archive_hash=$(nix hash to-sri --type sha256 "$archive_sha256")

  short_rev=$(printf %s "$latest_rev" | cut -c1-7)
  timestamp=$(date -u +%Y%m%d%H%M%S)
  new_version="unstable-$timestamp-$short_rev"

  jq --arg rev "$latest_rev" \
     --arg hash "$archive_hash" \
     --arg version "$new_version" \
     '.rev = $rev | .hash = $hash | .version = $version' \
     "$VERSION_JSON" > "$VERSION_JSON.tmp"

  mv "$VERSION_JSON.tmp" "$VERSION_JSON"

  git add "$VERSION_JSON"
  git commit -m "${pname}: ''${current_short} -> $short_rev"
''
