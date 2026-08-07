{pkgs}: let
  system = pkgs.stdenv.hostPlatform.system;
  # The gomod2nix CLI must come from the same nvfetcher-pinned source as
  # the builder injected by internal/discover.nix: nixpkgs ships v1.7.0,
  # whose CLI lacks `generate --with-deps` (build cache priming, added on
  # master together with the go-cache-env builder support).
  gomod2nix = (pkgs.extend (import ((import ../../internal/gomod2nix.nix) + "/overlay.nix"))).gomod2nix;
  script = pkgs.writeShellApplication {
    name = "update-package-hashes";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.git
      pkgs.gnugrep
      pkgs.nix
      pkgs.nix-update
      gomod2nix
    ];
    text = ''
      files="$(
        grep --recursive --files-with-matches --include='*.nix' \
          --extended-regexp '[[:alnum:]_]+Hash = "sha256-' pkgs || true
      )"
      if [[ -n "$files" ]]; then
        while IFS= read -r file; do
          attr="$(basename "$(dirname "$file")")"
          if nix eval ".#packages.${system}.$attr.pname" >/dev/null 2>&1; then
            echo "Updating hashes for $attr"
            nix-update --flake "$attr" --version skip --override-filename "$file"
          else
            echo "Skipping $attr: no matching flake package" >&2
          fi
        done <<<"$files"
      fi

      # Regenerate the gomod2nix lockfile of every gomod2nix package.
      # Convention: the package's pkgs/<name>/default.nix passes
      # `modules = ./gomod2nix.toml`; the file is committed to this
      # repository and regenerated here. --with-deps records the imported
      # dependency packages as cachePackages so the builder's go-cache-env
      # derivation pre-compiles them into a store-cached GOCACHE.
      # Requires network access to the Go module proxy (same precondition
      # as nix-update above).
      while IFS= read -r toml; do
        attr="$(basename "$(dirname "$toml")")"
        if nix eval ".#packages.${system}.$attr.pname" >/dev/null 2>&1; then
          echo "Regenerating gomod2nix.toml for $attr"
          src="$(nix build --no-link --print-out-paths ".#packages.${system}.''${attr}.src")"
          gomod2nix generate --with-deps --dir "$src" --outdir "pkgs/$attr"
        else
          echo "Skipping $toml: no matching flake package" >&2
        fi
      done < <(find pkgs -name gomod2nix.toml)
    '';
  };
in {
  update-hashes = {
    type = "app";
    program = "${script}/bin/update-package-hashes";
    meta.description = "Update package dependency hashes and gomod2nix lockfiles";
  };
}
