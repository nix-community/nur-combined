{
  lib,
  python3Packages,
  fetchFromGitHub,
  nur,
  nix-update-script,
  runCommand,
  testers,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gh-audit";
  version = "0.3.2";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "gh-audit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CcJX4OsvoLo5xT5g9fjvyLMbwC5v0OQIbgckUZVmMEc=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    pygithub
    pyyaml
    nur.repos.josh.python3-pyproject-fmt
  ];

  pythonImportsCheck = [ "gh_audit" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
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
