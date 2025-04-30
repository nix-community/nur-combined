{
  lib,
  stdenv,
  fetchgit,
  ant,
  jdk11,
  coreutils,
  findutils,
  makeWrapper,
}:

# https://sourceforge.net/p/wireshare/bugs/11/
let jdk = jdk11; in

stdenv.mkDerivation rec {
  pname = "wireshare";
  version = "6.0.2";

  # TODO replace jar files in lib/jars/ with jars from trusted sources (maven...)
  src = fetchgit {
    url = "https://git.code.sf.net/p/wireshare/code";
    rev = "49c61f0e252b22e4c329ad1e92aadef319bc439e";
    hash = "sha256-jpze1Da7cLZMDPl5FytsajUORFQAsccP3WD5eKXyT4E=";
  };

  postUnpack = ''
    sourceRoot+="/WireShare"
  '';

  nativeBuildInputs = [
    ant
    jdk
    makeWrapper
  ];

  propagatedBuildInputs = [
    jdk
  ];

  buildPhase = ''
    ant compile
  '';

  installPhase = ''
    mkdir -p $out/opt
    cp -r . $out/opt/wireshare
    mkdir -p $out/bin
    makeWrapper $out/opt/wireshare/run $out/bin/wireshare \
      --set PATH ${jdk}/bin:${coreutils}/bin:${findutils}/bin
  '';

  # ${paxtest}/lib/paxtest/execstack
  /*
  postFixup = ''
    # enable stack guard
    execstack -c $out/opt/wireshare/lib/native/linux/libjdic.so
  '';
  */

  meta = {
    description = "";
    homepage = "https://git.code.sf.net/p/wireshare/code";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "wireshare";
    platforms = lib.platforms.all;
  };
}
