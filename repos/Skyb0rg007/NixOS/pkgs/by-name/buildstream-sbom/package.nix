{
  lib,
  fetchFromGitLab,
  python3Packages,
  nix-update-script,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "buildstream-sbom";
  version = "1.2";
  pyproject = true;
  strictDeps = true;
  __structuredAttributes = true;

  src = fetchFromGitLab {
    owner = "BuildStream";
    repo = "buildstream-sbom";
    tag = finalAttrs.version;
    hash = "sha256-Eo9aoJFdYFQWE6K/C44Q45XUDH0R8I+Hxqu0EHkbIbk=";
  };

  build-system = [
    python3Packages.setuptools-scm
  ];

  dependencies = [
    python3Packages.pyyaml
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://gitlab.com/BuildStream/buildstream-sbom/";
    description = "Produce SBOMs describing BuildStream elements and dependencies";
    license = lib.licenses.asl20;
    changelog = "https://gitlab.com/BuildStream/buildstream-sbom/-/blob/${finalAttrs.version}/CHANGELOG.md";
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.all;
    mainProgram = "buildstream-sbom";
  };
})
