{ stdenv, fetchurl, makeWrapper, jre }:

stdenv.mkDerivation rec {
  name = "mill-${version}";
  version = "0.2.6";

  src = fetchurl {
    url = "https://github.com/lihaoyi/mill/releases/download/${version}/${version}";
    sha256 = "0khzr7i49i88rxx6x39m8ln08byv99prqysrsldc02hblb1ab6fn";
  };

  nativeBuildInputs = [ makeWrapper ];

  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/mill
    chmod +x $out/bin/mill
    wrapProgram $out/bin/mill --prefix PATH ":" ${jre}/bin ;
  '';

  meta = with stdenv.lib; {
    homepage = http://lihaoyi.com/mill/;
    description = "Your shiny new Scala build tool! ";
    license = licenses.mit;
  };
}
