{
  lib,
  fetchFromGitHub,
  nur,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  tmdb-index = python3Packages.buildPythonApplication {
    pname = "tmdb-index";
    version = "1.0.0-unstable-2026-06-30";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "tmdb-index";
      rev = "d57d92c75fb3e057f21dd96a6d4ba5b030e90814";
      hash = "sha256-5ccwVjLrA5Ce3OWlRWS/FCdusQ22RW4nDDw+ELjs5yY=";
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

    meta = {
      description = "Compact TMDB external ID index";
      homepage = "https://github.com/josh/tmdb-index";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "tmdb-index";
      broken = lib.strings.versionOlder python3Packages.polars.version "1.30";
    };
  };
in
tmdb-index.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    tmdb-index = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

      tests = {
        help =
          runCommand "test-tmdb-index-help"
            {
              __structuredAttrs = true;
              nativeBuildInputs = [ tmdb-index ];
            }
            ''
              tmdb-index --help
              touch $out
            '';
      };
    };
  }
)
