{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imdb-plex-sync";
  version = "0.4.1";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "imdb-plex-sync";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z7NpeVnwxTABvedAkaah4MXZ19J30cx6WbiS5/gG6is=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    pyarrow
  ];

  # TODO: Drop once nixpkgs ships pyarrow 26
  pythonRelaxDeps = [ "pyarrow" ];

  pythonImportsCheck = [ "imdb_plex_sync" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help = runCommand "test-imdb-plex-sync-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
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
  };
})
