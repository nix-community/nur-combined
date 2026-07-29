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
  version = "0.2.0-unstable-2026-07-23";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "trakt-plex-sync";
    rev = "10019ab745f5a5c085909b843bb8bd049d498639";
    hash = "sha256-h4v4q8oOjto54ztE5HBExrQ1hTXw4az0MewWdpjg8Pg=";
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
