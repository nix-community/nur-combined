# Modified from https://github.com/yilozt/nurpkg

{ lib
, stdenv
, bash
, makeWrapper
, fetchFromGitHub
, fetchurl
, v2ray
, iptables
}:

let
  pname = "v2raya-bin";
  version = "v2.0.0";
  name = "v2rayA-bin-${version}";
  
  src = fetchurl {
    url = "https://github.com/v2rayA/v2rayA/releases/download/v2.0.0/v2raya_linux_x64_2.0.0";
    sha256 = "sha256-ftCLheo1hKW5KGNfSMFFsC+7Z+O5DdJblx4j2u+KhKs=";
  };
in

stdenv.mkDerivation {
  inherit version name src;

  buildInputs = [ v2ray iptables bash ];
  nativeBuildInputs = [ makeWrapper ];
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 $src $out/bin/.v2rayA-wrapped
  '';

  postFixup = ''
    # Wrap v2rayA binary with currect $PATH
    makeWrapper $out/bin/.v2rayA-wrapped $out/bin/v2rayA \
      --suffix PATH : ${lib.makeBinPath [ v2ray iptables bash ]}
  '';

  meta = with lib; {
    description = "A Linux web GUI client of Project V which supports V2Ray, Xray, SS, SSR, Trojan and Pingtunnel";
    homepage = "https://github.com/v2rayA/v2rayA";
    mainProgram = "v2rayA";
    license = licenses.agpl3;
  };
}