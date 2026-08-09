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
      # Optional positional arguments: package names to force-refresh. When
      # given, only those packages are processed and change detection is
      # skipped for them. This is the escape hatch for hash drift that
      # source change detection cannot see — e.g. fetcher behavior changes
      # after a nixpkgs bump, or dependency edits committed without going
      # through nvfetcher: nix run .#update-hashes -- <name>
      declare -A forced=()
      for arg in "$@"; do
        forced[$arg]=1
      done
      declare -A handled=()

      is_forced() {
        [[ -n "''${forced[$1]:-}" ]]
      }

      # _sources entry name for a package whose source is not named
      # after its directory; mirrors the extraArgs exception table in
      # the repository root's default.nix (typenix-vscode is built from
      # sources.typenix). Everything else defaults to the dirname.
      declare -A source_names=([typenix-vscode]=typenix)

      # Change detection: _sources/generated.json is committed to git, so
      # the pre-update snapshot is simply the file at HEAD. Returns success
      # when the nvfetcher source entry for $1 differs between HEAD and the
      # working tree (or HEAD has no such file yet, e.g. before the first
      # commit — then everything counts as changed).
      source_changed() {
        local name=$1
        local old_entry new_entry
        old_entry=$(git show HEAD:_sources/generated.json 2>/dev/null | jq --compact-output --arg name "$name" '.[$name]' || true)
        new_entry=$(jq --compact-output --arg name "$name" '.[$name]' _sources/generated.json)
        [[ "$old_entry" != "$new_entry" ]]
      }

      # Refresh the vendored dependency hashes (vendorHash, npmDepsHash,
      # ...) of every package whose nvfetcher source changed. nix-update
      # recomputes a hash by building the FOD with a blanked outputHash,
      # which always re-downloads all dependencies (the fake-hash output
      # path can never be substituted from a cache), so running it for
      # unchanged packages — the common case on the daily cron — is pure
      # waste. Convention: any pkgs/<name>/default.nix containing a
      # `*Hash = "sha256-` attribute has its hashes refreshed by
      # nix-update. Packages without a _sources entry (not managed by
      # nvfetcher) count as changed: their hashes cannot be checked any
      # other way.
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

          if nix eval ".#packages.${system}.$attr.pname" >/dev/null 2>&1; then
            if ! is_forced "$attr"; then
              source_name="''${source_names[$attr]:-$attr}"
              new_entry=$(jq --compact-output --arg name "$source_name" '.[$name]' _sources/generated.json)
              if [[ "$new_entry" == "null" ]]; then
                echo "Note: $attr has no source in _sources/generated.json; cannot detect changes, refreshing anyway" >&2
              elif ! source_changed "$source_name"; then
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

      # A forced name that matched nothing above is almost certainly a
      # typo; say so instead of exiting quietly.
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
