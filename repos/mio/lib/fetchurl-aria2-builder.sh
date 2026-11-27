# This mirrors Nixpkgs' fetchurl builder for URL resolution, hashed mirrors,
# postFetch and output handling. Nixpkgs' builder must be reimplemented because
# its transfer path and fallback loop are built directly around curl flags;
# aria2 does not accept that curl command line.
source "$NIX_ATTRS_SH_FILE"

# This brings variables of the form "_mirror_<mirrorname>" into scope.
source "$mirrorsListFile"

if [[ -n "${curlOpts:-}" ]] || (( ${#curlOptsList[@]} > 0 )) || [[ -n "${NIX_CURL_FLAGS:-}" ]]; then
  echo "fetchurlAria2: curlOpts, curlOptsList, and NIX_CURL_FLAGS are not supported; use aria2Opts or NIX_ARIA2_FLAGS" >&2
  exit 1
fi

cookieFile="$TMPDIR/aria2-cookies.txt"
: > "$cookieFile"

aria2Args=(
  --no-conf
  --allow-overwrite=true
  --auto-file-renaming=false
  --file-allocation=none
  --continue=true
  --max-tries=3
  --retry-wait=2
  --connect-timeout="${NIX_CONNECT_TIMEOUT:-15}"
  --timeout=300
  --remote-time=false
  --load-cookies="$cookieFile"
  --save-cookies="$cookieFile"
  --user-agent="aria2 Nixpkgs/$nixpkgsVersion"
  --console-log-level=warn
  --summary-interval=0
)

if [[ -f "${SSL_CERT_FILE:-/no-cert-file.crt}" ]]; then
  aria2Args+=(--ca-certificate="$SSL_CERT_FILE")
else
  aria2Args+=(--check-certificate=false)
fi

if [[ -n "${netrcPhase:-}" ]]; then
  runPhase netrcPhase
  aria2Args+=(--netrc-path="$PWD/netrc")
else
  aria2Args+=(--no-netrc)
fi

aria2Args+=("${aria2Opts[@]}")
if [[ -n "${NIX_ARIA2_FLAGS:-}" ]]; then
  read -r -a nixAria2Flags <<< "$NIX_ARIA2_FLAGS"
  aria2Args+=("${nixAria2Flags[@]}")
fi

downloadedFile="$out"
if [ -n "$downloadToTemp" ]; then downloadedFile="$TMPDIR/file"; fi

tryDownload() {
  local url="$1"
  local target="$2"
  local targetDir
  local targetName
  targetDir="$(dirname "$target")"
  targetName="$(basename "$target")"
  echo
  echo "trying $url"

  aria2 "${aria2Args[@]}" \
    --dir="$targetDir" \
    --out="$targetName" \
    "$url"
}

finish() {
  local skipPostFetch="$1"

  set +o noglob

  if [[ "$executable" == "1" ]]; then
    chmod +x "$downloadedFile"
  fi

  if [ -z "$skipPostFetch" ]; then
    runHook postFetch
  fi

  exit 0
}

# URL list may contain ?. No glob expansion for that, please
set -o noglob

resolvedUrls=()

_resolveUrls() {
  local url
  for url in "${urls[@]}"; do
    if test "${url:0:9}" != "mirror://"; then
      resolvedUrls+=("${url}")
      continue
    fi

    if ! [[ "$url" =~ ^mirror://([^/ ]+)[/]([^ ]+)$ ]]; then
      echo "error: fetchurlAria2: $name: invalid mirror:// URL format: $url" >&2
      exit 1
    fi
    local site="${BASH_REMATCH[1]}"
    local filePath="${BASH_REMATCH[2]}"
    local varName="_mirror_${site}"
    local arrName="${varName}[@]"
    local envVarName="NIX_MIRRORS_${site}"

    local mirrorUrls
    if test -v "${arrName}"; then
      if test -n "${!envVarName}"; then
        echo "resolving url via NIX_MIRRORS_${site}"
        IFS=' ' read -r -a mirrorUrls <<< "${!envVarName}"
      else
        mirrorUrls=("${!arrName}")
      fi
    else
      echo "warning: unknown mirror:// site \`${site}'" >&2
      continue
    fi

    local mirrorUrl
    for mirrorUrl in "${mirrorUrls[@]}"; do
      resolvedUrls+=("${mirrorUrl}${filePath}")
    done
  done
}

_resolveUrls
set +o noglob

if test -n "$showURLs"; then
  echo "${resolvedUrls[*]}" > "$out"
  exit 0
fi

success=
for url in "${resolvedUrls[@]}"; do
  tryDownload "$url" "$downloadedFile" && success=1 && finish
done

if test -n "$NIX_HASHED_MIRRORS"; then
  IFS=' ' read -r -a hashedMirrors <<< "$NIX_HASHED_MIRRORS"
else
  hashedMirrors=("${_mirror_hashedMirrors[@]}")
fi

for mirror in "${hashedMirrors[@]}"; do
  url="$mirror/$outputHashAlgo/$outputHash"
  tryDownload "$url" "$out" && success=1 && finish skipPostFetch
done

echo "error: cannot download $name from any mirror" >&2
exit 1
