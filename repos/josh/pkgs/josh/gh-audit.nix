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
  version = "0.2.0-unstable-2026-08-07";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "gh-audit";
    rev = "fcc3d12d34a2c8ea0544baea2332aa51ef2964ab";
    hash = "sha256-S/+kAJLwEB/WYURl0Z00oyLdPe3wJpxUS3jcVSrtU3Q=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    pygithub
    pyyaml
  ];

  pythonImportsCheck = [ "gh_audit" ];

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
