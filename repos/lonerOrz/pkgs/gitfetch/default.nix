{
  lib,
  python3Packages,
  fetchFromGitHub,
  gh,
}:

python3Packages.buildPythonApplication rec {
  pname = "gitfetch";
  version = "1.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Matars";
    repo = "gitfetch";
    rev = "v${version}";
    hash = "sha256-HAZUdGCITr4in0K/LOSZaMHZpPjrHxcg7kAF1J0vl1I=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
    readchar
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        gh
      ]
    }"
  ];

  meta = {
    description = "A neofetch-style CLI tool for git provider statistics";
    homepage = "https://github.com/Matars/gitfetch";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ lonerOrz ];
    platforms = lib.platforms.all;
  };
}
