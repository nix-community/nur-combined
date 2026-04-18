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
  # SHA256 hash of the output directory (required)
  sha256,
  # Mirror domains to try as fallback, in order
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
in
  assert isValidId;
  assert lib.isInt p && p >= 0;
  assert builtins.isList mirrors && mirrors != [] && builtins.all isNonEmptyString mirrors;
  stdenvNoCC.mkDerivation {
    name = "pixiv-${idString}-p${toString p}";

    nativeBuildInputs = [curl cacert jq];

    buildCommand = ''
      # --- Step 1: Parallel API probe across all mirrors ---
      # Launch background curl requests to each mirror's API endpoint
      for mirror in ${lib.concatStringsSep " " mirrors}; do
        (
          start_time=$(date +%s%N)
          curl -s -X POST "https://api.$mirror/v1/generate" \
            -d "p=${idString}" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            --cacert ${cacert}/etc/ssl/certs/ca-bundle.crt \
            --connect-timeout 5 --max-time 15 \
            > "$TMPDIR/api_$mirror.json" 2>/dev/null
          end_time=$(date +%s%N)
          echo $((end_time - start_time)) > "$TMPDIR/time_$mirror.txt"
        ) &
      done

      # Wait for all background curls to finish
      wait

      # --- Step 1b: Pick the fastest successful mirror ---
      best_time=999999999999
      best_mirror=""
      for mirror in ${lib.concatStringsSep " " mirrors}; do
        response_file="$TMPDIR/api_$mirror.json"
        time_file="$TMPDIR/time_$mirror.txt"
        if [ -f "$response_file" ] && [ "$(jq -r '.success' "$response_file" 2>/dev/null)" = "true" ]; then
          elapsed=$(cat "$time_file" 2>/dev/null || echo 999999999999)
          if [ "$elapsed" -lt "$best_time" ]; then
            best_time=$elapsed
            best_mirror=$mirror
          fi
        fi
      done

      if [ -z "$best_mirror" ]; then
        echo "ERROR: All API mirrors failed for id=${idString}" >&2
        exit 1
      fi

      cp "$TMPDIR/api_$best_mirror.json" $TMPDIR/api_response.json
      echo "INFO: Using fastest mirror: $best_mirror (''${best_time}ns)" >&2

      # --- Step 2: Check API success ---
      success=$(jq -r '.success' $TMPDIR/api_response.json)
      if [ "$success" != "true" ]; then
        error_msg=$(jq -r '.error' $TMPDIR/api_response.json)
        echo "ERROR: pixiv.cat API returned failure for id=${idString}: $error_msg" >&2
        exit 1
      fi

      # --- Step 3: Extract metadata fields ---
      title=$(jq -r '.title' $TMPDIR/api_response.json)
      artist_id=$(jq -r '.artist.id' $TMPDIR/api_response.json)
      artist_name=$(jq -r '.artist.name' $TMPDIR/api_response.json)
      multiple=$(jq -r '.multiple' $TMPDIR/api_response.json)

      # --- Step 4: Sanitize artist_name and title ---
      # Replace forbidden characters with space, merge consecutive spaces, trim
      sanitize() {
        echo "$1" | sed 's/[\/\\:*?"<>|]/ /g' | sed 's/  */ /g' | sed 's/^ //;s/ $//' | {
          read -r val
          if [ -z "$val" ]; then echo "unknown"; else echo "$val"; fi
        }
      }

      sanitized_artist_name=$(sanitize "$artist_name")
      sanitized_title=$(sanitize "$title")

      # --- Step 5: Determine download URL ---
      url=""
      if [ "$multiple" = "true" ]; then
        url=$(jq -r ".original_urls_proxy[${toString p}]" $TMPDIR/api_response.json)
      else
        url=$(jq -r '.original_url_proxy' $TMPDIR/api_response.json)
      fi

      # --- Step 5b: Mirror fallback if URL is null/empty ---
      # Try best_mirror first (fastest from API probe), then fall back to others
      if [ -z "$url" ] || [ "$url" = "null" ]; then
        for ext in jpg png gif jpeg; do
          # Try best_mirror first
          for mirror in $best_mirror ${lib.concatStringsSep " " (lib.filter (m: m != "\${best_mirror}") mirrors)}; do
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

      # --- Step 6: Extract extension from URL ---
      ext=$(echo "$url" | sed 's/.*\.\([a-zA-Z0-9]*\)$/\1/')

      # --- Step 7: Download image ---
      curl -s -L "$url" --cacert ${cacert}/etc/ssl/certs/ca-bundle.crt > $TMPDIR/image

      # --- Step 8: Create output directory and copy image ---
      mkdir -p $out
      filename="''${artist_id}_${idString}_p${toString p}_''${sanitized_artist_name}_''${sanitized_title}.''${ext}"

      # Truncate filename to 255 bytes if needed
      filename_len=$(echo -n "$filename" | wc -c)
      if [ "$filename_len" -gt 255 ]; then
        # Keep extension, truncate the stem
        stem="''${filename%.''${ext}}"
        ext_len=$(echo -n ".$ext" | wc -c)
        max_stem_len=$((255 - ext_len))
        stem=$(echo -n "$stem" | head -c $max_stem_len)
        filename="$stem.$ext"
      fi

      cp $TMPDIR/image "$out/$filename"

      # --- Step 9: Write meta.json ---
      jq -n \
        --arg id "${idString}" \
        --argjson p ${toString p} \
        --arg title "$title" \
        --arg artist_id "$artist_id" \
        --arg artist_name "$artist_name" \
        --arg multiple "$multiple" \
        --arg url "$url" \
        --arg ext "$ext" \
        --arg filename "$filename" \
        '{id: $id, p: $p, title: $title, artist: {id: $artist_id, name: $artist_name}, multiple: ($multiple == "true"), url: $url, ext: $ext, filename: $filename}' \
        > "$out/meta.json"
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = sha256;
  }