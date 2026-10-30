{
  lib,
  callPackage,

  versionCommand,
  hashUrls,
  versionFile,

  prefetchUnpack ? false,
  extraPreScript ? "",
}:

let
  inherit (lib)
    toUpper
    replaceStrings
    concatStringsSep
    mapAttrsToList
    ;

  sanitize = system: toUpper (replaceStrings [ "-" ] [ "_" ] system);

  normalize = builtins.mapAttrs (_system: val: if builtins.isString val then { url = val; } else val);

  normalised = normalize hashUrls;

  preScript = ''
    VERSION=$(${versionCommand} 2>/dev/null) || VERSION=""

    CURRENT_VERSION=$(jq -r '.version' "${versionFile}" 2>/dev/null || echo "")
    if [ "$VERSION" = "$CURRENT_VERSION" ]; then
      # Version unchanged, but check if hashes are empty (from a previous failed run)
      HAS_EMPTY_HASHES=$(jq -r 'to_entries[] | select(.value == "") | .key' "${versionFile}" 2>/dev/null | head -1)
      if [ -z "$HAS_EMPTY_HASHES" ]; then
        cat "${versionFile}"
        exit 0
      fi
      # Hashes are empty despite version match — need to recompute them
      echo "[INFO] Version unchanged but hashes are empty, recomputing..." >&2
    fi

    tmpdir=$(mktemp -d)

    ${concatStringsSep "\n    " (
      mapAttrsToList (system: cfg: ''
        _CODE=$(curl -sI -o /dev/null -w "%{http_code}" "${cfg.url}" 2>/dev/null || echo "000")
        case "$_CODE" in
          2*|3*)
            (nix-prefetch-url ${if prefetchUnpack then "--unpack " else ""}"${cfg.url}" --type sha256 \
              | xargs nix-hash --to-sri --type sha256 > "$tmpdir/${system}" 2>/dev/null) || true
            # nix-prefetch-url may fail silently (e.g. HTTP/2 stream reset) and leave empty output
            if [ ! -s "$tmpdir/${system}" ]; then
              echo "[WARN] ${system}: ${cfg.url} prefetch failed (empty result), using placeholder hash" >&2
              echo "sha256-0000000000000000000000000000000000000000000=" > "$tmpdir/${system}"
            fi
            ;;
          *)
            echo "[WARN] ${system}: ${cfg.url} not reachable, using placeholder hash" >&2
            echo "sha256-0000000000000000000000000000000000000000000=" > "$tmpdir/${system}"
            ;;
        esac
      '') normalised
    )}

    wait

    ${concatStringsSep "\n    " (
      mapAttrsToList (system: _: ''
        _HASH_${sanitize system}=$(cat "$tmpdir/${system}")
      '') normalised
    )}
    rm -rf "$tmpdir"

    ${extraPreScript}
  '';

  commands = {
    version = "echo $VERSION";
  }
  // builtins.listToAttrs (
    builtins.map (
      system:
      let
        cfg = normalised.${system};
        hashKey = cfg.hashKey or "${system}-hash";
      in
      {
        name = hashKey;
        value = "echo $_HASH_${sanitize system}";
      }
    ) (builtins.attrNames normalised)
  );

in
callPackage ./json.nix { inherit preScript commands; }
