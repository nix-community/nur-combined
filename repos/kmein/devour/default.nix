{ stdenv, xdo, makeWrapper, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "devour";
  version = "master";

  src = fetchFromGitHub {
    owner = "salman-abedin";
    repo = "devour";
    rev = "ceb871c3046ce290c27e2887365b9a19ca38113c";
    sha256 = "0f2jb8knx7lqy6wmf3rchgq2n2dj496lm8vgcs58rppzrmsk59d5";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ xdo ];

  DESTDIR="$(out)";

  fixupPhase = ''
    wrapProgram $out/bin/devour --prefix PATH ":" ${xdo}/bin ;
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/salman-abedin/devour";
    description = "Window Manager agnostic swallowing feature for terminal emulators";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
