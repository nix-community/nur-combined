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
  version = "1.1.0-unstable-2026-08-11";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tmdb-index";
    rev = "9f2b9065328ab965bbd01b4dbf961a2ffe5a20b3";
    hash = "sha256-XAfwlxmeXmxBD1v64jkFQ5F2vtwoYe+Wz958vxuWTvQ=";
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
