# This file was generated by GoReleaser. DO NOT EDIT.
# vim: set ft=nix ts=2 sw=2 sts=2 et sta
{
system ? builtins.currentSystem
, lib
, fetchurl
, installShellFiles
, stdenvNoCC
}:
let
  shaMap = {
    i686-linux = "1q3xr0g0xnf5y0q4zq3gw34i5fvbi30xd7h1k1dnj09fknbmpyjp";
    x86_64-linux = "1n7xqmb5f5a69mp8zgawwnrfbnidiqr6lr87r9yhfkwp2j7mqc4r";
    armv7l-linux = "1by4wqh6i1kkb4dl7zn4cv7yldgprkqiixfp8i7wwyps41g123gc";
    aarch64-linux = "1yrr7va0gjph4g0ki06s9yd9r04x8scahnqsrz1wpp56y4van372";
    x86_64-darwin = "07rfz1hfj3wna2ijjazk3wnhjgdr63xdzalbwgq72d9gfdyi6gpn";
    aarch64-darwin = "07dpyhn9w4cyr3ny3szrbriv9jzlcnci6q4p0wh4qallqbxfpnyi";
  };

  urlMap = {
    i686-linux = "https://github.com/charmbracelet/confettysh/releases/download/v1.1.1/confettysh_1.1.1_Linux_i386.tar.gz";
    x86_64-linux = "https://github.com/charmbracelet/confettysh/releases/download/v1.1.1/confettysh_1.1.1_Linux_x86_64.tar.gz";
    armv7l-linux = "https://github.com/charmbracelet/confettysh/releases/download/v1.1.1/confettysh_1.1.1_Linux_arm.tar.gz";
    aarch64-linux = "https://github.com/charmbracelet/confettysh/releases/download/v1.1.1/confettysh_1.1.1_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/charmbracelet/confettysh/releases/download/v1.1.1/confettysh_1.1.1_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/charmbracelet/confettysh/releases/download/v1.1.1/confettysh_1.1.1_Darwin_arm64.tar.gz";
  };
in
stdenvNoCC.mkDerivation {
  pname = "confettysh";
  version = "1.1.1";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./confettysh $out/bin/confettysh
  '';

  system = system;

  meta = {
    description = "Confetty over SSH";
    homepage = "https://charm.sh/";
    license = lib.licenses.mit;

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "armv7l-linux"
      "i686-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
