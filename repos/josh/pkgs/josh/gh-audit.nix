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
  version = "0.3.1";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "josh";
    repo = "gh-audit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Jn+rtVqlKvVh/umoKPuQQrHcOwT2G3mkz5lsQKOXmIo=";
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

  # The unformatted-pyproject rule shells out to `sys.executable -m pyproject_fmt`,
  # which does not inherit the site directories the console script adds inline.
  makeWrapperArgs = [
    "--prefix"
    "PYTHONPATH"
    ":"
    (python3Packages.makePythonPath [
      nur.repos.josh.python3-pyproject-fmt
      nur.repos.josh.python3-toml-fmt-common
    ])
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

    pyproject-fmt =
      runCommand "test-gh-audit-pyproject-fmt"
        {
          __structuredAttrs = true;
        }
        ''
          sed 's|^exec .*|exec ${python3Packages.python.interpreter} "$@"|' \
            ${finalAttrs.finalPackage}/bin/gh-audit >run-python
          chmod +x run-python
          ./run-python -c 'import subprocess, sys; sys.exit(subprocess.run([sys.executable, "-m", "pyproject_fmt", "--version"]).returncode)'
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
