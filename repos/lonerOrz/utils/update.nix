{
  writeShellApplication,
  nix,
  jq,
  gnugrep,
  gawk,

  pname,
  versionFile,
  fetchMetaCommand,
  # auto - 自动获取哈希, none - 仅更新元数据
  updateMethod ? "auto",
}:

writeShellApplication {
  name = "update-${pname}";

  runtimeInputs = [
    nix
    jq
    gnugrep
    gawk
  ];

  text = ''
    set -euo pipefail

    PNAME="${pname}"
    VERSION_FILE="${toString versionFile}"
    BACKUP_FILE="$VERSION_FILE.bak"
    METHOD="${updateMethod}"

    _cleanup() {
      local ret=$?
      if [ "$ret" -ne 0 ]; then
        if [ -f "$BACKUP_FILE" ]; then
          echo ">> [!] Update failed (code $ret). Restoring $VERSION_FILE..." >&2
          mv "$BACKUP_FILE" "$VERSION_FILE"
        fi
        [ -f err.txt ] && { echo ">> [!] Last Nix error log:" >&2; cat err.txt >&2; }
      else
        rm -f "$BACKUP_FILE"
      fi
      rm -f err.txt
      exit "$ret"
    }

    trap _cleanup EXIT
    cp "$VERSION_FILE" "$BACKUP_FILE"

    echo ">> [1/3] Fetching upstream metadata..."
    meta=$(${fetchMetaCommand})

    if ! echo "$meta" | jq -e . >/dev/null 2>&1; then
      echo "Error: fetchMetaCommand output is not valid JSON" >&2
      exit 1
    fi

    is_changed=$(jq --argjson meta "$meta" -n -r '
      input as $old | $meta | to_entries |
      map(.key as $k | .value as $v | if $old[$k] == $v then empty else true end) |
      if length > 0 then "true" else "false" end
    ' "$VERSION_FILE")

    if [ "$is_changed" = "false" ]; then
      echo "OK: $PNAME is already up to date."
      exit 0
    fi

    # 打印版本变化信息
    old_ver=$(jq -r '.version // "unknown"' "$VERSION_FILE")
    new_ver=$(echo "$meta" | jq -r '.version // "unknown"')
    echo "OK: Metadata fetched ($old_ver -> $new_ver)."

    jq --argjson meta "$meta" '. * $meta' "$VERSION_FILE" > tmp.json && mv tmp.json "$VERSION_FILE"

    if [ "$METHOD" = "auto" ]; then
      echo ">> [2/3] Assigning unique dummy hashes..."
      declare -A placeholders
      declare -a keys
      declare -A resolved_map

      mapfile -t keys < <(jq -r 'to_entries[] | select(.value | startswith("sha256-")) | .key' "$VERSION_FILE")
      total_keys=''${#keys[@]}

      if [ "$total_keys" -gt 0 ]; then
        chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for i in "''${!keys[@]}"; do
          key="''${keys[$i]}"
          char=''${chars:$i:1}
          placeholder="sha256-$(awk -v c="$char" -v n=43 'BEGIN { for(j=0;j<n;j++) printf "%s", c; }')="

          placeholders["$key"]="$placeholder"
          echo "Assigning: $key -> $char (placeholder)..."
          jq --arg k "$key" --arg v "$placeholder" '.[$k] = $v' "$VERSION_FILE" > tmp.json && mv tmp.json "$VERSION_FILE"
        done

        echo ">> [3/3] Resolving real hashes via Nix build..."
        resolved_count=0
        while [ "$resolved_count" -lt "$total_keys" ]; do
          echo "Status: Resolved $resolved_count/$total_keys. Building..."

          if nix build ".#$PNAME" --no-link 2>err.txt; then
            echo "Success: All hashes are now valid."
            break
          fi

          mapfile -t specs < <(grep -oP 'specified:.*\Ksha256-[A-Za-z0-9+/=]+' err.txt)
          mapfile -t gots < <(grep -oP 'got:.*\Ksha256-[A-Za-z0-9+/=]+' err.txt)

          if [ ''${#specs[@]} -eq 0 ]; then
            echo "Error: Build failed without hash mismatch." >&2
            exit 1
          fi

          new_found=false
          for idx in "''${!specs[@]}"; do
            spec_hash="''${specs[$idx]}"
            got_hash="''${gots[$idx]}"
            for key in "''${keys[@]}"; do
              [[ -n "''${resolved_map[$key]:-}" ]] && continue
              prefix=$(echo "''${placeholders[$key]}" | cut -c 1-15)
              if [[ "$spec_hash" == "$prefix"* ]]; then
                echo "Resolved $key: $got_hash"
                jq --arg k "$key" --arg h "$got_hash" '.[$k] = $h' "$VERSION_FILE" > tmp.json && mv tmp.json "$VERSION_FILE"
                resolved_map["$key"]=1
                resolved_count=$((resolved_count + 1))
                new_found=true
                break
              fi
            done
          done

          if [ "$new_found" = "false" ]; then
            echo "Error: No new hashes could be resolved from logs." >&2
            exit 1
          fi
          truncate -s 0 err.txt
        done
        echo "Finish: All $total_keys hashes updated."
      else
        echo "Info: No hashes to update."
      fi
    elif [ "$METHOD" = "none" ]; then
      echo ">> Strategy 'none': Skipping hash resolution loop."
    fi

    echo "Done: $PNAME update successful!"
  '';
}
