{ stdenv, lib, makeWrapper, fetchFromGitHub, imagemagick, ghostscript }:

stdenv.mkDerivation rec {
  pname = "pdf2png";
  version = "0.1.0.0";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = pname;
    rev = version; 
    sha256 = "1yq87vm30ylq4hrqwci6iy0q2yrxdb90fxf2mrh66azhf1w2y5g9";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D pdf2png.sh $out/bin/pdf2png
  '';

  postFixup = ''
    wrapProgram $out/bin/pdf2png --prefix PATH : ${lib.makeBinPath [ imagemagick ghostscript]}
  '';

  meta = with stdenv.lib; {
    description = "A simple script to convert a PDF into multiple PNGs.";
    homepage = https://github.com/emmanuelrosa/pdf2png;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
