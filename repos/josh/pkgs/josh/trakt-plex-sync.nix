{
  lib,
  python3Packages,
  fetchFromGitHub,
  nur,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "trakt-plex-sync";
  version = "0.2.0-unstable-2026-08-06";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "trakt-plex-sync";
    rev = "403531c0f49d43d1843d164dfc6ca55bc78dcfc5";
    hash = "sha256-Tr+vRPBDCtVVkjHrYQtyNLo/ANBUa8BdX9br8YuUvnI=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    nur.repos.josh.python3-lru-cache
    plexapi
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  # Upstream has no CLI framework, so --version and --help tests are not possible
  passthru.tests = {
    import =
      runCommand "test-trakt-plex-sync-import"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [
            (python3Packages.python.withPackages (_: [
              (python3Packages.toPythonModule finalAttrs.finalPackage)
            ]))
          ];
        }
        ''
          TRAKT_CLIENT_ID=x TRAKT_ACCESS_TOKEN=x python -c "import trakt_plex_sync"
          touch $out
        '';
  };

  meta = {
    description = "Sync Trakt history to Plex library";
    homepage = "https://github.com/josh/trakt-plex-sync";
    license = lib.licenses.mit;
    mainProgram = "trakt-plex-sync";
    platforms = lib.platforms.all;
  };
})
