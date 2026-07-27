{ stdenv, lib, fetchzip, makeWrapper, jre, protobuf }:
stdenv.mkDerivation rec {
  pname = "scalapbc";
  version = "0.11.1";
  name = "${pname}-${version}";
  src = fetchzip {
    url = "https://github.com/scalapb/ScalaPB/releases/download/v${version}/${name}.zip";
    sha256 = "sha256-641rRQCaA+tgJhLZRASPv0Ntvi0b38yrkvInaSfrOmU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir $out
    cp -r * $out/
  '';

  postFixup = ''
    wrapProgram $out/bin/${pname} \
      --add-flags "--protoc=${protobuf}/bin/protoc" \
      --set JAVA_HOME ${jre.home}
  '';
}
