# Refresh static-URL dependency hashes; update-pins handles coupled URLs and hashes.
{pkgs}: let
  system = pkgs.stdenv.hostPlatform.system;
  script = pkgs.writeShellApplication {
    name = "update-hashes";
    runtimeInputs = [
      pkgs.findutils
      pkgs.git
      pkgs.gnugrep
      pkgs.jq
      pkgs.nix
      pkgs.nix-update
    ];
    text = ''
      # Optional package names force-refresh only those packages.
      declare -A forced=()
      for arg in "$@"; do
        forced[$arg]=1
      done
      declare -A handled=()

      is_forced() {
        [[ -n "''${forced[$1]:-}" ]]
      }

      # Package-to-source naming exceptions.
      declare -A source_names=([typenix-vscode]=typenix)

      # Compare each nvfetcher source with HEAD.
      source_changed() {
        local name=$1
        local old_entry new_entry
        old_entry=$(git show HEAD:_sources/generated.json 2>/dev/null | jq --compact-output --arg name "$name" '.[$name]' || true)
        new_entry=$(jq --compact-output --arg name "$name" '.[$name]' _sources/generated.json)
        [[ "$old_entry" != "$new_entry" ]]
      }

      # Refresh hash-bearing packages when their source changed, is unknown, or still uses the placeholder hash.
      files="$(
        grep --recursive --files-with-matches --include='*.nix' \
          --extended-regexp '[[:alnum:]_]+Hash = "sha256-' pkgs || true
      )"
      if [[ -n "$files" ]]; then
        while IFS= read -r file; do
          attr="$(basename "$(dirname "$file")")"

          if [[ "''${#forced[@]}" -gt 0 ]]; then
            is_forced "$attr" || continue
          fi

          # Use getAttr for non-identifier package names.
          if nix eval ".#packages.${system}" --apply "pkgs: (builtins.getAttr \"$attr\" pkgs).pname" >/dev/null 2>&1; then
            if ! is_forced "$attr"; then
              source_name="''${source_names[$attr]:-$attr}"
              new_entry=$(jq --compact-output --arg name "$source_name" '.[$name]' _sources/generated.json)
              if [[ "$new_entry" == "null" ]]; then
                echo "Note: $attr has no source in _sources/generated.json; cannot detect changes, refreshing anyway" >&2
              elif ! source_changed "$source_name" && ! grep --quiet 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=' "$file"; then
                echo "Skipping $attr: source unchanged"
                continue
              fi
            fi
            echo "Updating hashes for $attr"
            handled[$attr]=1
            nix-update --flake "$attr" --version skip --override-filename "$file"
          else
            echo "Skipping $attr: no matching flake package" >&2
          fi
        done <<<"$files"
      fi

      # Warn about unmatched forced names.
      for arg in "''${!forced[@]}"; do
        if [[ -z "''${handled[$arg]:-}" ]]; then
          echo "WARNING: forced package $arg was not refreshed (no vendored hash or no matching flake package)" >&2
        fi
      done
    '';
  };
in {
  update-hashes = {
    type = "app";
    program = "${script}/bin/update-hashes";
    meta.description = "Refresh vendored dependency hashes with nix-update for packages whose sources changed";
  };
}
