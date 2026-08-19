# Fix npm lockfiles before prefetching dependencies.
final: prev: let
  inherit (final.lib) getExe;

  fetchNpmDeps = args:
    (prev.fetchNpmDeps args).overrideAttrs (old: {
      # Run after lockfile patches.
      preBuild =
        (old.preBuild or "")
        + ''
          if [[ -f npm-shrinkwrap.json ]]; then
            npm_lockfile=npm-shrinkwrap.json
          elif [[ -f package-lock.json ]]; then
            npm_lockfile=package-lock.json
          else
            npm_lockfile=
          fi

          # Skip complete lockfiles.
          if [[ -n "$npm_lockfile" ]] && ${getExe final.jq} -e '
            any(
              (.packages // {} | to_entries[]);
              (.key | contains("node_modules/"))
                and (.value | has("resolved") | not)
            )
          ' "$npm_lockfile" >/dev/null; then
            echo "Repairing missing npm lockfile metadata in $npm_lockfile"
            ${getExe final.npm-lockfile-fix} -r "$npm_lockfile"
          fi
        '';

      # Configure requests without changing fetchNpmDeps SSL settings.
      env =
        (old.env or {})
        // {
          REQUESTS_CA_BUNDLE = "${final.cacert}/etc/ssl/certs/ca-bundle.crt";
        };
    });
in {
  inherit fetchNpmDeps;

  # Use the wrapped fetcher.
  buildNpmPackage = prev.buildNpmPackage.override {inherit fetchNpmDeps;};
}
