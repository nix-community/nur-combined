{ makeWrapper, stdenv, gnumake, fetchFromGitHub, ffmpeg, xdotool, slop, libnotify }:
let
  binPath = [
    slop
    ffmpeg
    xdotool
  ];
in stdenv.mkDerivation rec {
  pname = "giph";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "phisch";
    repo = "giph";
    rev = "${version}";
    sha256 = "1kd42dz4qvzks8dwljnhlnh9j5rgdkdc8zp67igv57yfsfrwl91b";
  };

  installFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [ gnumake makeWrapper ];
  buildInputs = [ libnotify ];

  postFixup = ''
    wrapProgram $out/bin/giph --prefix PATH : ${stdenv.lib.makeBinPath binPath}
  '';

  meta = with stdenv.lib; {
    description = "Captures your screen and saves it as a gif";
    license = licenses.mit;
    homepage = "https://github.com/phisch/giph";
    maintainers = with maintainers; [ extends ];
    platforms = platforms.all;
  };
}
