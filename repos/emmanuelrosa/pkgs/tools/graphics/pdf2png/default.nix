{ stdenv, lib, makeWrapper, fetchFromGitHub, imagemagick, ghostscript }:

stdenv.mkDerivation rec {
  pname = "pdf2png";
  version = "0.2.0.0";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = pname;
    rev = version; 
    sha256 = "039j7izz4c1gvgk2dbn37ai0xj0vfakhh7rn6nxg0fkbk53gkb9w";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D pdf2png.sh $out/bin/pdf2png
    install -D pdf2jpg.sh $out/bin/pdf2jpg
  '';

  postFixup = ''
    wrapProgram $out/bin/pdf2png --prefix PATH : ${lib.makeBinPath [ imagemagick ghostscript]}
    wrapProgram $out/bin/pdf2jpg --prefix PATH : ${lib.makeBinPath [ imagemagick ghostscript]}
  '';

  meta = with lib; {
    description = "A simple script to convert a PDF into multiple PNGs.";
    homepage = https://github.com/emmanuelrosa/pdf2png;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
