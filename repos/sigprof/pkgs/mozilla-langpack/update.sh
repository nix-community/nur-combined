#! /usr/bin/env nix-shell
#! nix-shell --pure -i bash -p cacert coreutils curl git gnugrep gnupg gnused jq libxml2.bin nix

set -eux -o pipefail

source_dir="${0%/*}"

# Set up a secure temporary directory with automatic cleanup.
original_umask="$(umask)"
umask 077
tmpdir=
cleanup() {
  [ -n "$tmpdir" ] && rm -rf "$tmpdir" ||:
}
trap cleanup EXIT
tmpdir="$(mktemp -d)"

# Set up a clean environment.
mkdir "$tmpdir/home"
export HOME="$tmpdir/home"
mkdir "$tmpdir/gnupghome"
export GNUPGHOME="$tmpdir/gnupghome"

# Get the signing key to verify the signatures on hash lists.
gpg --receive-keys 14F26682D0916CDD81E37B6D61B7B526D98F0353

# Language pack install dir, indexed by the app name.
declare -A installDir
installDir[firefox]="share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
installDir[thunderbird]="share/mozilla/extensions/{3550f703-e582-4d05-9a08-453d09bdfdc6}"

# Addon ID suffix, indexed by the app name.
declare -A addonIdSuffix
addonIdSuffix[firefox]="firefox.mozilla.org"
addonIdSuffix[thunderbird]="thunderbird.mozilla.org"

# URL and version list file for a particular app, indexed by the app name.
declare -A releaseUrl releaseList

# getReleaseList appName
#
# Prepare the URL and version list file for the specified app.  Downloads the
# version list if that had not been done before.
#
getReleaseList() {
  local app="$1" && shift
  if [ -n "${releaseUrl[$app]:-}" ] && [ -n "${releaseList[$app]:-}" ]; then
    return 0
  fi
  local url="https://archive.mozilla.org/pub/${app}/releases/"
  local index="$tmpdir/releaseIndex-$app"
  local list="$tmpdir/releaseList-$app"
  curl -o "$index" "$url"
  xmllint --html --xpath '//a/text()' "$index" | \
    sed -e '/^[^0-9]/d' -e '/funnelcake/d' -e 's,/$,,' -e '/b/d' -e '/rc/d' | \
    sort --reverse --version-sort \
    > "$list"
  releaseUrl[$app]="$url"
  releaseList[$app]="$list"
}

# getAppLatestVersion appName majorNumber maybeESR
#
# Outputs the latest version of the app specified in `appName` with the major
# number specified in `majorNumber` and the ESR status specified in `maybeESR`
# (which should be either "" or "esr").  If `majorNumber` is empty, outputs the
# latest available version of the app with the specified ESR status.
#
getAppLatestVersion() {
  local app="$1" && shift
  local majorNumber="$1" && shift
  local maybeESR="$1" && shift

  getReleaseList "$app"
  cat "${releaseList[$app]}" | \
    if [ -n "$majorNumber" ]; then
      grep "^${majorNumber}\."
    else
      cat
    fi | \
    if [ -n "$maybeESR" ]; then
      grep -m 1 'esr$'
    else
      grep -m 1 -v 'esr$'
    fi
}

# The latest version for the given `${app}:${majorNumber}:${maybeESR}`
# combination.
declare -A appMajorToVersion

# processAppNameWithVersion "${app}-${appVersion}${maybeESR}"
#
# Parses the app name with the version number appended after `-` and optional
# `esr` designation at the end, then finds the latest available version with
# the same major version number and ESR status and saves the result in
# `appMajorToVersion`.
#
processAppNameWithVersion() {
  local nameWithVersion="$1" && shift
  local app="${nameWithVersion%-*}"
  local version="${nameWithVersion##*-}"
  local majorNumber="${version%%.*}"
  local maybeESR=
  if [ -z "${version##*esr}" ]; then
    maybeESR=esr
  fi
  if [ -z "${appMajorToVersion[${app}:${majorNumber}:${maybeESR}]:-}" ]; then
    getReleaseList "$app"
    local latestVersion="$( getAppLatestVersion "$app" "$majorNumber" "$maybeESR" )" ||:
    if [ -n "$latestVersion" ]; then
      appMajorToVersion[${app}:${majorNumber}:${maybeESR}]="$latestVersion"
    fi
  fi
}

# If there are no command line parameters, use the default list of packages.
if [ $# = 0 ]; then
  defaultAppNames=(firefox firefox-esr thunderbird)
  # Get the list of packages from the `nixpkgs` input of the current flake.
  flakeUrl="$( cd "$source_dir" && nix flake metadata --json | jq -r '.url' )"
  currentSystem="$( nix eval --raw --impure --expr 'builtins.currentSystem' )"
  for pkg in "${defaultAppNames[@]}"; do
    # `--impure` is needed to work with a dirty flake
    nameWithVersion="$( nix eval --no-warn-dirty --impure --raw --expr "(builtins.getFlake \"$flakeUrl\").inputs.nixpkgs.legacyPackages.\"$currentSystem\".${pkg}.name" )"
    set -- "$@" "$nameWithVersion"
  done
fi

# Parse the command line.
for nameWithVersion in "$@"; do
  processAppNameWithVersion "$nameWithVersion"
done

# Add latest versions for all mentioned apps.
declare -A allApps
for appKey in "${!appMajorToVersion[@]}"; do
  app="${appKey%%:*}"
  majorNumber="${appKey#*:}"
  maybeESR="${majorNumber#*:}"
  majorNumber="${majorNumber%%:*}"
  maybeESR="${maybeESR%%:*}"
  allApps[$app:$maybeESR]=1
done
for appKey in "${!allApps[@]}"; do
  app="${appKey%%:*}"
  maybeESR="${appKey##*:}"
  latestVersion="$( getAppLatestVersion "$app" "" "$maybeESR" )"
  processAppNameWithVersion "$app-$latestVersion"
done

# Process all requested apps and versions.
for appKey in "${!appMajorToVersion[@]}"; do
  app="${appKey%%:*}"
  majorNumber="${appKey#*:}"
  maybeESR="${majorNumber#*:}"
  majorNumber="${majorNumber%%:*}"
  maybeESR="${maybeESR%%:*}"
  version="${appMajorToVersion[$appKey]}"
  majorKey="${majorNumber}${maybeESR}"
  url="${releaseUrl[$app]}"

  curl -o $HOME/shasums "$url$version/SHA512SUMS"
  curl -o $HOME/shasums.asc "$url$version/SHA512SUMS.asc"
  gpgv --keyring=$GNUPGHOME/pubring.kbx $HOME/shasums.asc $HOME/shasums

  for arch in linux-x86_64 linux-i686; do
    cat "$HOME/shasums" | \
      ( grep -F "${arch}" || true ) | \
      ( grep '\.xpi$' || true ) | \
      while read -r sha512 filename rest; do
        this_url="${url}${version}/${filename}"
        this_locale="${filename##*/}"
        this_locale="${this_locale%.xpi}"
        hash="$(nix hash to-sri --type sha512 "$sha512")"
        cat >> "$tmpdir/sources.mjson" <<EOF
{
  "${app}": {
    "${majorKey}": {
      "${arch}": {
        "${this_locale}": {
          "version": "${version}",
          "url": "${this_url}",
          "hash": "${hash}"
        }
      }
    }
  }
}
EOF
        addon_install_dir="${installDir[$app]}"
        if [ -n "$addon_install_dir" ]; then
          rm -rf "$tmpdir/nar"
          mkdir -p "$tmpdir/nar/out/$addon_install_dir"
          curl -o "$tmpdir/nar/file.xpi" "$this_url"
          printf '%s  %s\n' "$sha512" "$tmpdir/nar/file.xpi" | \
            sha512sum -c -
          addon_path="${addon_install_dir}/langpack-${this_locale}@${addonIdSuffix[$app]}.xpi"
          install -m444 "$tmpdir/nar/file.xpi" "$tmpdir/nar/out/${addon_path}"
          nar_hash="$(nix hash path --sri --type sha512 "$tmpdir/nar/out")"
          cat >> "$tmpdir/sources.mjson" <<EOF
{
  "${app}": {
    "${majorKey}": {
      "${arch}": {
        "${this_locale}": {
          "narHash": {
            "${addon_path}": "${nar_hash}"
          }
        }
      }
    }
  }
}
EOF
        fi
      done
  done
done

# Write the output file.
umask "$original_umask"
jq -Sn 'reduce inputs as $x ({}; . * $x)' < "$tmpdir/sources.mjson" > "$tmpdir/sources.json"
mv "$tmpdir/sources.json" "$source_dir/sources.json"

# vim:set sw=2 sta et:
