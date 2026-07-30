{
  lib,
  python3Packages,
  fetchFromGitHub,
  nur,
  runCommand,
  nix-update-script,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "trakt-plex-sync";
  version = "0.2.0-unstable-2026-07-30";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "trakt-plex-sync";
    rev = "b86b8a3fefc5eda8aba7836b46ba1991d6a9a0c8";
    hash = "sha256-UsPqjDHtba6fkLWl5Kf7fSpYsM6lBsTyPqCDXeQGycs=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    nur.repos.josh.python3-lru-cache
    plexapi
    requests
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
    platforms = lib.platforms.all;
    mainProgram = "trakt-plex-sync";
  };
})
