{
  lib,
  stdenvNoCC,
  curl,
  cacert,
  jq,
}: {
  # Pixiv illustration ID (required, positive integer or numeric string matching ^[1-9][0-9]*$)
  id,
  # Page number, 0-based (default: 0 = first page)
  p ? 0,
  # SHA256 hash of the image file (required)
  sha256,
  # Mirror domains to try, in order
  mirrors ? [
    "pixiv.re"
    "pixiv.cat"
    "pixiv.nl"
  ],
}: let
  isValidId =
    (lib.isInt id && id > 0) || (lib.isString id && builtins.match "^[1-9][0-9]*$" id != null);
  idString = toString id;
  isNonEmptyString = value: lib.isString value && value != "";

  # --- Internal drv: fetch raw image via API (non-fixed-output, allows network) ---
  rawImage = stdenvNoCC.mkDerivation {
    name = "pixiv-${idString}-p${toString p}-raw";
    nativeBuildInputs = [curl cacert jq];
    buildCommand = ''
      # --- Parallel API probe across all mirrors ---
      for mirror in ${lib.concatStringsSep " " mirrors}; do
        (
          curl -s -X POST "https://api.$mirror/v1/generate" \
            -d "p=${idString}" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            --cacert ${cacert}/etc/ssl/certs/ca-bundle.crt \
            --connect-timeout 5 --max-time 15 \
            > "$TMPDIR/api_$mirror.json" 2>/dev/null
        ) &
      done
      wait

      # Pick first successful mirror
      best_mirror=""
      for mirror in ${lib.concatStringsSep " " mirrors}; do
        if [ -f "$TMPDIR/api_$mirror.json" ] && [ "$(jq -r '.success' "$TMPDIR/api_$mirror.json" 2>/dev/null)" = "true" ]; then
          best_mirror=$mirror
          break
        fi
      done

      if [ -z "$best_mirror" ]; then
        echo "ERROR: All API mirrors failed for id=${idString}" >&2
        exit 1
      fi

      cp "$TMPDIR/api_$best_mirror.json" $TMPDIR/api_response.json

      # --- Extract download URL ---
      multiple=$(jq -r '.multiple' $TMPDIR/api_response.json)
      url=""
      if [ "$multiple" = "true" ]; then
        url=$(jq -r ".original_urls_proxy[${toString p}]" $TMPDIR/api_response.json)
      else
        url=$(jq -r '.original_url_proxy' $TMPDIR/api_response.json)
      fi

      # Fallback to mirror direct URL if API proxy is empty
      if [ -z "$url" ] || [ "$url" = "null" ]; then
        for ext in jpg png gif jpeg; do
          for mirror in ${lib.concatStringsSep " " mirrors}; do
            if [ "${toString p}" = "0" ]; then
              for suffix in "$ext" "1.$ext"; do
                candidate="https://$mirror/${idString}-$suffix"
                code=$(curl -s -L -o /dev/null -w "%{http_code}" --cacert ${cacert}/etc/ssl/certs/ca-bundle.crt "$candidate")
                if [ "$code" = "200" ]; then
                  url="$candidate"
                  break 3
                fi
              done
            else
              candidate="https://$mirror/${idString}-${toString (p + 1)}.$ext"
              code=$(curl -s -L -o /dev/null -w "%{http_code}" --cacert ${cacert}/etc/ssl/certs/ca-bundle.crt "$candidate")
              if [ "$code" = "200" ]; then
                url="$candidate"
                break 2
              fi
            fi
          done
        done
      fi

      if [ -z "$url" ] || [ "$url" = "null" ]; then
        echo "ERROR: Could not determine download URL for id=${idString} p=${toString p}" >&2
        exit 1
      fi

      # --- Extract extension from URL ---
      ext=$(echo "$url" | sed 's/.*\.\([a-zA-Z0-9]*\)$/\1/')

      # --- Download image ---
      mkdir -p $out
      curl -s -L "$url" --cacert ${cacert}/etc/ssl/certs/ca-bundle.crt > "$out/image.$ext"
    '';
  };

  # --- IFD: read extension from rawImage output filename ---
  files = builtins.readDir rawImage;
  filename = lib.head (lib.attrNames files);
  ext = lib.last (lib.splitString "." filename);
in
  assert isValidId;
  assert lib.isInt p && p >= 0;
  assert builtins.isList mirrors && mirrors != [] && builtins.all isNonEmptyString mirrors;
  stdenvNoCC.mkDerivation {
    name = "pixiv-${idString}-p${toString p}.${ext}";
    nativeBuildInputs = [];
    buildCommand = ''
      cp ${rawImage}/${filename} $out
    '';
    outputHashAlgo = "sha256";
    outputHash = sha256;
  }
