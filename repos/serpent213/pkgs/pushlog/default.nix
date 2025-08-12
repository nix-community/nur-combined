{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "pushlog";
  version = "0.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "serpent213";
    repo = "pushlog";
    # tag = "v${version}";
    rev = "3588e69c5dab897c84c91023dd88469426dfaca3";
    sha256 = "sha256-QHf2n29AbUSt9YULzXImM3ow8puFU7UzGM5amz1hiuY=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    fuzzywuzzy
    levenshtein
    pyyaml
    systemd
  ];

  checkInputs = with python3Packages; [
    pytestCheckHook
  ];

  meta = {
    description = "Lightweight Python daemon that filters and forwards systemd journal to Pushover";
    homepage = "https://github.com/serpent213/pushlog";
    platforms = lib.platforms.linux;
    mainProgram = "pushlog";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ ];
  };
}
