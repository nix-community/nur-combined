{
  lib,
  python3Packages,
  fetchFromGitHub,
  gh,
}:

python3Packages.buildPythonApplication rec {
  pname = "gitfetch";
  version = "1.3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Matars";
    repo = "gitfetch";
    rev = "v${version}";
    hash = "sha256-dVJdc0iqcl/+s3v+ui6XtKRlOuYoFVYWlG0GtTZLr5o=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
    readchar
    webcolors
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
