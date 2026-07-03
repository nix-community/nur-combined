{
  lib,
  fetchFromGitHub,
  python3Packages,
  runCommand,
  nix-update-script,
}:
let
  gh-audit = python3Packages.buildPythonApplication {
    pname = "gh-audit";
    version = "0.2.0-unstable-2026-07-03";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "gh-audit";
      rev = "41b66ba5c6dbf7946aa3830f7c51fbf6e4e14040";
      hash = "sha256-M7UIohJQ1EbUuFKhb6IZit5EG6fmA4b0PERi8nBdack=";
    };

    pyproject = true;
    __structuredAttrs = true;

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      click
      pygithub
      pyyaml
    ];

    meta = {
      description = "Personal GitHub repository meta linting tool for consistent configuration";
      homepage = "https://github.com/josh/gh-audit";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      mainProgram = "gh-audit";
    };
  };
in
gh-audit.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    gh-audit = finalAttrs.finalPackage;
  in
  {
    passthru = previousAttrs.passthru // {
      updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

      tests = {
        help =
          runCommand "test-gh-audit-help"
            {
              __structuredAttrs = true;
              nativeBuildInputs = [ gh-audit ];
            }
            ''
              gh-audit --help
              touch $out
            '';
      };
    };
  }
)
