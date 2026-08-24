{
  fetchFromGitHub,

  python3Packages,
  beets,
  lib,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "beets-describe";
  version = "0.0.5";
  src = fetchFromGitHub {
    owner = "adamjakab";
    repo = "BeetsPluginDescribe";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+aAKQ0JKl8R4/5kmcAfCXNR77onlMoFkraE3JI5Quy4=";
  };

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [
    beets
  ];

  dependencies = with python3Packages; [
    termtables
    numpy
    pandas
    termplotlib
  ];

  nativeCheckInputs = with python3Packages; [
    pytest
    coverage
    mock
    six
    pyyaml
  ];

  meta = {
    description = "A beets plugin for obsessive-compulsive music geeks to describe what's in their library";
    homepage = "https://github.com/adamjakab/BeetsPluginDescribe";
    license = lib.licenses.mit;
    inherit (beets.meta) platforms;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
