{ lib
, stdenv
, fetchFromGitHub
, poppler_utils
, texlive
}:

stdenv.mkDerivation rec {
  pname = "pdfselect";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "aur-archive";
    repo = "pdfselect";
    rev = "ff9481795580220214c8222b9c21ab7aee9aa83f";
    hash = "sha256-pKDEDuSe3mt1oWnluyvMI8RNOU2frdwep9Afx2Gj5Pk=";
  };

  propagatedBuildInputs = [
    texlive.combined.scheme-small # same as in pdfjam.nix
  ];

  buildPhase = ''
    gcc -O2 -o pdfselect_i pdfselect_i.c

    chmod +x pdfselect
    sed -i 's|^pdflatex=pdflatex$|pdflatex=${texlive.combined.scheme-small}/bin/pdflatex|' pdfselect
    sed -i 's|^pdfinfo=pdfinfo$|pdfinfo=${poppler_utils}/bin/pdfinfo|' pdfselect
    sed -i "s|pdfselect_i|$out/bin/.pdfselect_i|" pdfselect
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp pdfselect pdfselect_i $out/bin
    mv $out/bin/pdfselect_i $out/bin/.pdfselect_i
  '';

  meta = with lib; {
    description = "Select pages from a pdf file";
    homepage = "https://github.com/aur-archive/pdfselect";
    license = with licenses; [ gpl1Plus ];
    maintainers = with maintainers; [ ];
  };
}
