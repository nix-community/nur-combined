{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
, coreutils
, gawk
, gnused
, imagemagick
}:

stdenv.mkDerivation rec {
  pname = "lsix";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "hackerb9";
    repo = "lsix";
    rev = version;
    sha256 = "sha256-mOueSNhf1ywG4k1kRODBaWRjy0L162BAO1HRPaMMbFM=";
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm 0755 lsix $out/bin/lsix
    wrapProgram $out/bin/lsix --set PATH \
      "${lib.makeBinPath [ coreutils gawk gnused imagemagick ]}"
  '';

  meta = with lib; {
    description = "Shows thumbnails in terminal using sixel graphics";
    homepage = "https://github.com/hackerb9/lsix";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ plabadens ];
  };
}
