{ pkgs ? import <nixpkgs> { }
, lib
}:

with pkgs;

stdenv.mkDerivation rec {
  pname = "kotlin-language-server";
  version = "1.1.1";

  src = fetchzip {
    url = "https://github.com/fwcd/kotlin-language-server/releases/download/${version}/server.zip";
    sha256 = "aG+1LcL9d1FR3ZDyyRA82wgIe6JIxYTO5SKz2Srs9ok=";
  };

  buildPhase = ''
    sed -i -e "2i JAVA_HOME=${jre8}/" ./bin/kotlin-language-server
    cat ./bin/kotlin-language-server
  '';

  installPhase = ''
    mkdir -p $out
    cp -r bin $out/bin
    cp -r lib $out/lib
  '';

  propagatedBuildInputs = [ jre8 ];

  meta = with lib; {
    description = "Intelligent Kotlin support for any editor/IDE using the Language Server Protocol";
    homepage = "https://github.com/fwcd/kotlin-language-server";
    license = licenses.mit;
    maintainers = with maintainers; [ zachcoyle ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
