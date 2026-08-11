{ lib
, stdenv
, fetchFromGitHub
, pdfjam
, texlive
}:

stdenv.mkDerivation rec {
  pname = "pdfjam-extras";
  version = "unstable-2019-11-18";

  src = fetchFromGitHub {
    owner = "rrthomas";
    repo = "pdfjam-extras";
    rev = "622e03add59db004144c0b41722a09b3b29d6d3e";
    hash = "sha256-2aSqd1A8Y53UWaOkAgfqJEGw50EM/I9VIqyYxPq5c/s=";
  };

  propagatedBuildInputs = [
    # TODO? add pdfjam to PATH
    pdfjam
    texlive.combined.scheme-small
  ];

  installPhase = ''
    mkdir -p $out
    cp -r bin $out
    sed -i '2i\export PATH=$PATH:${pdfjam}/bin:${texlive.combined.scheme-small}/bin' $out/bin/*
    mkdir -p $out/share/man
    cp -r man1 $out/share/man
  '';

  meta = with lib; {
    description = "Some unsupported 'wrapper' scripts for pdfjam: pdfnup, pdfpun, pdfjoin, pdf90, pdf180, pdf270, pdfflip, pdfbook, pdfjam-pocketmod, pdfjam-slides3up, pdfjam-slides6up";
    homepage = "https://github.com/rrthomas/pdfjam-extras";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
  };
}
