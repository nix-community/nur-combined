# Modified from https://github.com/yilozt/nurpkg

{ lib
, stdenv
, bash
, makeWrapper
, fetchFromGitHub
, fetchurl
}:


let
  inherit ((builtins.getFlake
    "github:NixOS/nixpkgs/8de8b98839d1f20089582cfe1a81207258fcc1f1").legacyPackages.${stdenv.system})
    v2ray iptables; # fetch v2ray 4
in

stdenv.mkDerivation {
  name = "v2raya-bin";
  version = "v1.5.9.1698.1";

  src = fetchurl {
    url = "https://github.com/v2rayA/v2rayA/releases/download/v1.5.9.1698.1/v2raya_linux_x64_1.5.9.1698.1";
    sha256 = "sha256:114d6jfhi6b4lwlq1l5nj4041nc1w5c1s407js6cdhi13sa4blzz";
  };

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
    license = licenses.agpl3Only;
  };
}