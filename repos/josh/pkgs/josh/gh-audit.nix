{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
  testers,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gh-audit";
  version = "0.2.0-unstable-2026-07-24";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "gh-audit";
    rev = "9994cdd4ddf0a03a55c60800b9c45900fad2e88d";
    hash = "sha256-lpIOWp1AJxwJ96YOmSo7F8jb80SWfl7ZQU0Jfll3oB0=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    pygithub
    pyyaml
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = lib.lists.head (lib.strings.splitString "-unstable-" finalAttrs.version);
    };

    help =
      runCommand "test-gh-audit-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          gh-audit --help
          touch $out
        '';
  };

  meta = {
    description = "Personal GitHub repository meta linting tool for consistent configuration";
    homepage = "https://github.com/josh/gh-audit";
    license = lib.licenses.mit;
    mainProgram = "gh-audit";
    platforms = lib.platforms.all;
  };
})
