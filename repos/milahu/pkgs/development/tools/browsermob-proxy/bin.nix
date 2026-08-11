{
  lib,
  stdenv,
  fetchurl,
  unzip,
  makeWrapper,
  jre8,
}:

let
  # https://github.com/lightbody/browsermob-proxy/issues/878
  jre = jre8;
in

stdenv.mkDerivation rec {
  pname = "browsermob-proxy-bin";
  version = "2.1.4";

  src = fetchurl {
    url = "https://github.com/lightbody/browsermob-proxy/releases/download/browsermob-proxy-${version}/browsermob-proxy-${version}-bin.zip";
    hash = "sha256-J8QIBBGt/5GVhukJxmTHO+u4uov8rqJZzlgyciLl6Ps=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/opt
    cp -r . $out/opt/browsermob-proxy
    mkdir -p $out/bin
    makeWrapper $out/opt/browsermob-proxy/bin/browsermob-proxy $out/bin/browsermob-proxy \
      --set JAVACMD ${jre}/bin/java
  '';

  meta = {
    description = "A free utility to help web developers watch and manipulate network traffic from their AJAX applications";
    homepage = "https://github.com/lightbody/browsermob-proxy";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "browsermob-proxy";
    platforms = lib.platforms.all;
  };
}
