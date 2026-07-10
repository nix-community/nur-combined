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
    version = "0.2.0-unstable-2026-07-10";

    src = fetchFromGitHub {
      owner = "josh";
      repo = "gh-audit";
      rev = "71265184e80e73be12ced5edc91e8cd8db043352";
      hash = "sha256-3FH4PHZqb1MSRllccj0JSEuXJ1WuUa5ai4MnPtpFEFQ=";
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
