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

  sanitize = system: toUpper (replaceStrings ["-"] ["_"] system);

  normalize = builtins.mapAttrs (_system: val:
    if builtins.isString val then { url = val; }
    else val
  );

  normalised = normalize hashUrls;

  preScript = ''
    VERSION=$(${versionCommand})

    CURRENT_VERSION=$(jq -r '.version' "${versionFile}" 2>/dev/null || echo "")
    [ "$VERSION" = "$CURRENT_VERSION" ] && cat "${versionFile}" && exit 0

    tmpdir=$(mktemp -d)

    ${concatStringsSep "\n    " (mapAttrsToList (system: cfg: ''
      _CODE=$(curl -sI -o /dev/null -w "%{http_code}" "${cfg.url}" 2>/dev/null || echo "000")
      case "$_CODE" in
        2*|3*)
          (nix-prefetch-url ${if prefetchUnpack then "--unpack " else ""}"${cfg.url}" --type sha256 \
            | xargs nix-hash --to-sri --type sha256 > "$tmpdir/${system}") &
          ;;
        *)
          echo "[WARN] ${system}: ${cfg.url} not reachable, using placeholder hash" >&2
          echo "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" > "$tmpdir/${system}"
          ;;
      esac
    '') normalised)}

    wait

    ${concatStringsSep "\n    " (mapAttrsToList (system: _: ''
      _HASH_${sanitize system}=$(cat "$tmpdir/${system}")
    '') normalised)}
    rm -rf "$tmpdir"

    ${extraPreScript}
  '';

  commands = { version = "echo $VERSION"; } // builtins.listToAttrs (builtins.map
    (system: let
      cfg = normalised.${system};
      hashKey = cfg.hashKey or "${system}-hash";
    in {
      name = hashKey;
      value = "echo $_HASH_${sanitize system}";
    })
    (builtins.attrNames normalised));

in
callPackage ./json.nix { inherit preScript commands; }
