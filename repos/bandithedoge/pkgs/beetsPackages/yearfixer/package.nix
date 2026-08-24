{
  beets,
  fetchFromGitHub,
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "beets-yearfixer";
  version = "0.0.5";
  src = fetchFromGitHub {
    owner = "adamjakab";
    repo = "BeetsPluginYearFixer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TDRkCihp+hB33e9LCBpUye+KobpTPrDMutMa4zHJQ68=";
  };

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [
    beets
  ];

  dependencies = with python3Packages; [
    requests
  ];

  nativeCheckInputs = with python3Packages; [
    pytest
    coverage
    mock
    six
    pyyaml
  ];

  meta = {
    description = "A beets plugin for obsessive-compulsive music geeks to fix missing album release date";
    homepage = "https://github.com/adamjakab/BeetsPluginYearFixer";
    license = lib.licenses.mit;
    inherit (beets.meta) platforms;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
