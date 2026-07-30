{
  lib,
  python3Packages,
  fetchFromGitHub,
  nur,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-plex-sync";
  version = "0.2.0";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-plex-sync";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nRGxekhGjaxU7uLAvIpB/B6+zx3ztlWkjG4kMg0yRbA=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    nur.repos.josh.polars
  ];

  pythonImportsCheck = [ "imdb_plex_sync" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help =
      runCommand "test-imdb-plex-sync-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          imdb-plex-sync --help
          touch $out
        '';
  };

  meta = {
    description = "Sync IMDb watchlist to Plex watchlist";
    homepage = "https://github.com/josh/imdb-plex-sync";
    license = lib.licenses.mit;
    mainProgram = "imdb-plex-sync";
    platforms = lib.platforms.all;
    broken = lib.strings.versionOlder nur.repos.josh.polars.version "1.30";
  };
})
