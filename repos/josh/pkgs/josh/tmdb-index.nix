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
  version = "1.0.0-unstable-2026-08-04";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tmdb-index";
    rev = "f13acf8307f9db34fa47567efa7053333c9f5079";
    hash = "sha256-Q7AD21jtSieqJFSg3IV4bc6OJx/mAqC+sPr5zWkzKE8=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    nur.repos.josh.polars
    tqdm
  ];

  pythonImportsCheck = [ "tmdb_index" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    # TODO: Add --version test

    help =
      runCommand "test-tmdb-index-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
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
    broken = lib.strings.versionOlder nur.repos.josh.polars.version "1.30";
  };
})
