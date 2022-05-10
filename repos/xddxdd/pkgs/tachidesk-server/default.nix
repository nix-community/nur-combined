{ stdenv
, lib
, fetchurl
, unzip
, jre_headless
, makeWrapper
, ...
} @ args:

let
  ver = "0.6.2";
  rev = "1074";
in
stdenv.mkDerivation rec {
  pname = "tachidesk-server";
  version = "${ver}-r${rev}";
  src = fetchurl {
    url = "https://github.com/Suwayomi/Tachidesk-Server/releases/download/v${ver}/Tachidesk-Server-v${ver}-r${rev}.jar";
    sha256 = "sha256-/s+bc/W5mFp5hNLgHsOJRHcWkKbyzaSqm26raJ6nmjI=";
  };
  dontUnpack = true;

  nativeBuildInputs = [ unzip makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/opt
    cp ${src} $out/opt/tachidesk-server.jar

    makeWrapper ${jre_headless}/bin/java $out/bin/tachidesk-server \
      --add-flags "-jar" \
      --add-flags "$out/opt/tachidesk-server.jar" \
  '';

  meta = with lib; {
    description = "A rewrite of Tachiyomi for the Desktop";
    homepage = "https://github.com/Suwayomi/Tachidesk-Server";
    license = licenses.mpl20;
  };
}
