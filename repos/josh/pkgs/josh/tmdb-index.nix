{
  lib,
  python3Packages,
  fetchFromGitHub,
  nur,
  nix-update-script,
  runCommand,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tmdb-index";
  version = "1.2.0";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tmdb-index";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hFqBItcpBS9B6/rtaqn0krxkeikUJL1FHd6yKZWp6Ys=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    nur.repos.josh.polars
    tqdm
  ];

  # TODO: Drop once nixpkgs ships polars 2
  pythonRelaxDeps = [ "polars" ];

  pythonImportsCheck = [ "tmdb_index" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help = runCommand "test-tmdb-index-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; } ''
      tmdb-index --help
      touch $out
    '';
  };

  meta = {
    description = "Compact TMDB external ID index";
    homepage = "https://github.com/josh/tmdb-index";
    license = lib.licenses.mit;
    mainProgram = "tmdb-index";
    platforms = lib.platforms.all;
  };
})
