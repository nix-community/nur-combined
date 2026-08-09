{pkgs}: let
  system = pkgs.stdenv.hostPlatform.system;
  # The gomod2nix CLI must come from the same nvfetcher-pinned source as
  # the builder injected by internal/discover.nix: nixpkgs ships v1.7.0,
  # whose CLI lacks `generate --with-deps` (build cache priming, added on
  # master together with the go-cache-env builder support).
  gomod2nix = (pkgs.extend (import ((import ../../internal/gomod2nix.nix) + "/overlay.nix"))).gomod2nix;
  script = pkgs.writeShellApplication {
    name = "update-lockfiles";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.git
      pkgs.gnugrep
      pkgs.jq
      pkgs.nix
      pkgs.crate2nix
      pkgs.cargo
      gomod2nix
    ];
    text = ''
      export LANG=en_US.UTF-8

      # Optional positional arguments: package names to force-regenerate.
      # When given, only those packages are processed and change detection
      # is skipped for them. This covers the rare case where a source
      # change was already committed (so the git-HEAD comparison below
      # sees no diff) but the committed lockfile is stale.
      declare -A forced=()
      for arg in "$@"; do
        forced[$arg]=1
      done
      declare -A handled=()

      is_forced() {
        [[ -n "''${forced[$1]:-}" ]]
      }

      # Change detection: _sources/generated.json is committed to git, so
      # the pre-update snapshot is simply the file at HEAD. Returns
      # success when the nvfetcher source entry for $1 differs between
      # HEAD and the working tree (or HEAD has no such file yet, e.g.
      # before the first commit — then everything counts as changed).
      source_changed() {
        local name=$1
        local old_entry new_entry
        old_entry=$(git show HEAD:_sources/generated.json 2>/dev/null | jq --compact-output --arg name "$name" '.[$name]' || true)
        new_entry=$(jq --compact-output --arg name "$name" '.[$name]' _sources/generated.json)
        [[ "$old_entry" != "$new_entry" ]]
      }

      # Regenerate the crate2nix build file of every package that uses
      # crate2nix. Convention: the package's pkgs/<name>/default.nix imports
      # its generated Cargo.nix from ./Cargo.nix next to itself; the file is
      # committed to this repository and (re)generated here whenever the
      # package's source entry changed or the file does not exist yet (e.g.
      # a newly added crate2nix package). crate2nix is only needed at
      # generation time; evaluation and builds use nixpkgs' buildRustCrate.
      # NOTE: the generated files must NOT live under _sources/ — nvfetcher
      # treats that directory as its own output and deletes unknown files
      # there on every run, which would defeat the change detection above.
      # Evaluate the raw nvfetcher sources with the nixpkgs pinned by this
      # repository's flake (works on CI without channels).
      sources_expr='
        let
          flake = builtins.getFlake (toString ./.);
          pkgs = flake.inputs.nixpkgs.legacyPackages.${system};
        in
          pkgs.callPackage (flake.outPath + "/_sources/generated.nix") {}'

      for file in pkgs/*/default.nix; do
        grep --quiet --fixed-strings './Cargo.nix' "$file" || continue
        name=$(basename "$(dirname "$file")")

        if [[ "''${#forced[@]}" -gt 0 ]]; then
          is_forced "$name" || continue
        else
          new_entry=$(jq --compact-output --arg name "$name" '.[$name]' _sources/generated.json)
          if [[ "$new_entry" == "null" ]]; then
            echo "Skipping $name: no source named $name in _sources/generated.json" >&2
            continue
          fi
          if ! source_changed "$name" && [[ -f "pkgs/$name/Cargo.nix" ]]; then
            continue
          fi
        fi

        echo "Regenerating pkgs/$name/Cargo.nix"
        handled[$name]=1
        src=$(nix build --no-link --print-out-paths --impure --expr "($sources_expr).\"$name\".src")

        tmp=$(mktemp -d)
        cp -r "$src/." "$tmp/src"
        chmod -R u+w "$tmp/src"

        # The cargo manifest is usually at the source root. Otherwise fall
        # back to the single first-level manifest (e.g. codegraph, whose
        # only Rust project lives in codegraph-kernel/). The -f path is
        # passed relative to the source root so the command crate2nix
        # records in the generated header is deterministic — an absolute
        # path would embed the ephemeral mktemp directory and turn every
        # regeneration into a spurious diff.
        manifest_args=()
        if [[ ! -f "$tmp/src/Cargo.toml" ]]; then
          shopt -s nullglob
          manifests=("$tmp/src"/*/Cargo.toml)
          shopt -u nullglob
          if [[ ''${#manifests[@]} -ne 1 ]]; then
            echo "ERROR: $name: no root Cargo.toml and ''${#manifests[@]} first-level manifests; cannot pick one" >&2
            exit 1
          fi
          manifest_args=(-f "$(basename "$(dirname "''${manifests[0]}")")/Cargo.toml")
        fi

        (cd "$tmp/src" && crate2nix generate "''${manifest_args[@]}")

        cp "$tmp/src/Cargo.nix" "pkgs/$name/Cargo.nix"
        rm -rf "$tmp"
      done

      # Regenerate the gomod2nix lockfile of every gomod2nix package whose
      # source changed (or that was forced). Convention: the package's
      # pkgs/<name>/default.nix passes `modules = ./gomod2nix.toml`; the
      # file is committed to this repository and regenerated here.
      # --with-deps records the imported dependency packages as
      # cachePackages so the builder's go-cache-env derivation pre-compiles
      # them into a store-cached GOCACHE.
      # Requires network access to the Go module proxy.
      while IFS= read -r toml; do
        attr="$(basename "$(dirname "$toml")")"
        if [[ "''${#forced[@]}" -gt 0 ]]; then
          is_forced "$attr" || continue
        fi
        if nix eval ".#packages.${system}.$attr.pname" >/dev/null 2>&1; then
          if ! is_forced "$attr"; then
            new_entry=$(jq --compact-output --arg name "$attr" '.[$name]' _sources/generated.json)
            if [[ "$new_entry" == "null" ]]; then
              echo "Note: $attr has no source in _sources/generated.json; cannot detect changes, regenerating anyway" >&2
            elif ! source_changed "$attr"; then
              continue
            fi
          fi
          echo "Regenerating gomod2nix.toml for $attr"
          handled[$attr]=1
          src="$(nix build --no-link --print-out-paths ".#packages.${system}.''${attr}.src")"
          gomod2nix generate --with-deps --dir "$src" --outdir "pkgs/$attr"
        else
          echo "Skipping $toml: no matching flake package" >&2
        fi
      done < <(find pkgs -name gomod2nix.toml)

      # A forced name that matched nothing above is almost certainly a
      # typo; say so instead of exiting quietly.
      for arg in "''${!forced[@]}"; do
        if [[ -z "''${handled[$arg]:-}" ]]; then
          echo "WARNING: forced package $arg was not regenerated (not a crate2nix/gomod2nix package or no matching flake package)" >&2
        fi
      done
    '';
  };
in {
  update-lockfiles = {
    type = "app";
    program = "${script}/bin/update-lockfiles";
    meta.description = "Regenerate crate2nix Cargo.nix and gomod2nix.toml lockfiles for changed sources";
  };
}
