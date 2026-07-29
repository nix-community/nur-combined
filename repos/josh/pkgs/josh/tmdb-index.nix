{
  lib,
  fetchFromGitHub,
  nur,
  python3Packages,
  runCommand,
  nix-update-script,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tmdb-index";
  version = "1.0.0-unstable-2026-07-28";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tmdb-index";
    rev = "ecb2c6e859d4e34314b597d029e0a119c3fed87c";
    hash = "sha256-ZRqaLuGU+mm1TRoxupQ/OphVUd/F1pENJ2e7NmZVlF0=";
  };

  pyproject = true;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    nur.repos.josh.polars
    tqdm
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
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
    platforms = lib.platforms.all;
    mainProgram = "tmdb-index";
    broken = lib.strings.versionOlder python3Packages.polars.version "1.30";
  };
})
