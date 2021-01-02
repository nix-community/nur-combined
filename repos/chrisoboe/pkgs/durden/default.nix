{ stdenv, fetchFromGitHub, arcan }:

stdenv.mkDerivation rec {
  pname = "durden";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "letoram";
    repo = "durden";
    rev = "${version}";
    sha256 = "03ry8ypsvpjydb9s4c28y3iffz9375pfgwq9q9y68hmj4d89bjvz";
  };

  buildInputs = [ arcan ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/arcan/appl
    mkdir -p $out/bin
    cp -r ./durden $out/share/arcan/appl/
    cp ./distr/durden $out/bin/durden
  '';

  meta = with stdenv.lib; {
    homepage = "https://durden.arcan-fe.com";
    description = "Next Generation Desktop Environment";
    platforms = platforms.linux;
    maintainers = [ "chris@oboe.email" ];
  };
}

