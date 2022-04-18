{ stdenv
, fetchurl
, unzip
, jre_headless
, makeWrapper
, ...
} @ args:

let
  ver = "0.6.3";
  rev = "1087";
in
stdenv.mkDerivation rec {
  pname = "tachidesk-server";
  version = "${ver}-r${rev}";
  src = fetchurl {
    url = "https://github.com/Suwayomi/Tachidesk-Server/releases/download/v${ver}/Tachidesk-Server-v${ver}-r${rev}.jar";
    sha256 = "sha256-rs586/Mcl3GX52IwTVGCsqGBERQNo9/6mhIxGJOsLOQ=";
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
}
