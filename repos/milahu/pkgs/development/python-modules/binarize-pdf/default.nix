{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  pymupdf,
  pillow,
  doxapy,
}:

buildPythonApplication rec {
  pname = "binarize-pdf";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "binarize-pdf";
    rev = "4bd905e59cf018a9a41ede9244b1b2e47d7a069d";
    hash = "sha256-Z/4/St3fEANJFKqJW3KzmFRMMoGoJ1Dn116j15k/bs4=";
  };

  pyproject = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pymupdf
    pillow
    doxapy
  ];

/*
  postInstall = ''
    mv -v $out/bin/binarize-pdf.py $out/bin/binarize-pdf
  '';
*/

  meta = with lib; {
    description = "convert ugly gray-on-yellow PDF files to pretty black-on-white PDF files";
    homepage = "https://github.com/milahu/binarize-pdf";
    license = licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "binarize-pdf";
    platforms = platforms.all;
  };
}
