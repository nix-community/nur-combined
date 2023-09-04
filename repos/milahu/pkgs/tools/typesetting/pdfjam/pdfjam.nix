{ lib
, stdenv
, fetchFromGitHub
, zip
, texlive
}:

stdenv.mkDerivation rec {
  pname = "pdfjam";
  version = "3.07";

  src = fetchFromGitHub {
    owner = "rrthomas";
    repo = "pdfjam";
    rev = "v${version}";
    hash = "sha256-nxFObYFLxzHZMhpc+hpSNod5gnHT9yHsIrftVaC0stA=";
  };

  buildInputs = [
    zip # for tests.zip
  ];

  propagatedBuildInputs = [
    # pdflatex, pdfpages.sty, atbegshi.sty, ...
    # see latex-dependency.txt
    texlive.combined.scheme-small
  ];

  buildPhase = ''
    ./build.sh
  '';

  installPhase = ''
    cd built_package/pdfjam-${version}
    mkdir -p $out
    cp -r bin $out
    sed -i '2i\export PATH=$PATH:${texlive.combined.scheme-small}/bin' $out/bin/*
    mkdir -p $out/share/man
    cp -r man1 $out/share/man
    mkdir -p $out/opt/pdfjam
    cp pdfjam.conf README.md $out/opt/pdfjam
  '';

  meta = with lib; {
    description = "The pdfjam package for manipulating PDF files";
    homepage = "https://github.com/rrthomas/pdfjam";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
  };
}
