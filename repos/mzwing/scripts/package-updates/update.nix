{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "update-packages";
    runtimeInputs = [
      pkgs.nix
      pkgs.nvfetcher
      pkgs.crate2nix
      pkgs.cargo
      pkgs.jq
    ];
    text = ''
      export LANG=en_US.UTF-8
      key_flags=()
      [[ -f "$HOME/Secrets/nvfetcher.toml" ]] && key_flags+=(-k "$HOME/Secrets/nvfetcher.toml")
      [[ -f secrets.toml ]] && key_flags+=(-k secrets.toml)

      # Snapshot the sources before the update so the crate2nix step below
      # can tell which package sources actually changed.
      old_sources=$(mktemp)
      trap 'rm -f "$old_sources"' EXIT
      cp _sources/generated.json "$old_sources"

      nix flake update
      nvfetcher "''${key_flags[@]}" -c nvfetcher.toml -o _sources "$@"

      # Regenerate the crate2nix build file of every package that uses
      # crate2nix. Convention: the package's pkgs/<name>/default.nix imports
      # its generated Cargo.nix from ./Cargo.nix next to itself; the file is
      # committed to this repository and (re)generated here whenever the
      # package's source entry changed or the file does not exist yet (e.g.
      # a newly added crate2nix package). crate2nix is only needed at
      # generation time; evaluation and builds use nixpkgs' buildRustCrate.
      # NOTE: the generated files must NOT live under _sources/ — nvfetcher
      # treats that directory as its own output and deletes unknown files
      # there on every run, which would defeat the change detection below.
      system=$(nix eval --impure --raw --expr builtins.currentSystem)
      # Evaluate the raw nvfetcher sources with the nixpkgs pinned by this
      # repository's flake (works on CI without channels).
      sources_expr='
        let
          flake = builtins.getFlake (toString ./.);
          pkgs = flake.inputs.nixpkgs.legacyPackages.'"$system"';
        in
          pkgs.callPackage (flake.outPath + "/_sources/generated.nix") {}'

      for file in pkgs/*/default.nix; do
        grep --quiet --fixed-strings './Cargo.nix' "$file" || continue
        name=$(basename "$(dirname "$file")")

        old_entry=$(jq --compact-output --arg name "$name" '.[$name]' "$old_sources")
        new_entry=$(jq --compact-output --arg name "$name" '.[$name]' _sources/generated.json)
        if [[ "$new_entry" == "null" ]]; then
          echo "Skipping $name: no source named $name in _sources/generated.json" >&2
          continue
        fi
        if [[ "$old_entry" == "$new_entry" && -f "pkgs/$name/Cargo.nix" ]]; then
          continue
        fi

        echo "Regenerating pkgs/$name/Cargo.nix"
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
    '';
  };
in {
  update = {
    type = "app";
    program = "${script}/bin/update-packages";
    meta.description = "Update package sources with nvfetcher";
  };
}
