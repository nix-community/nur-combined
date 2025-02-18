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
    i686-linux = "0zkq07pjns5cr7vb1sn8fbk86kx6cprdpgcsh5v9bvpqbhg6iv10";
    x86_64-linux = "1rkvd3y2h5cf8r4a3c33g0jxp5vy3h6rspb7qvhkwr2p8vbkhb3v";
    armv7l-linux = "1nm7gmg5ij3bikjn012zb9h4wndcgc67zpbsxi6fhsvqv766w540";
    aarch64-linux = "002ragwh6in987ja50sxasm70iivniwjpq0ssqg3d7q39vm6i0n0";
    x86_64-darwin = "0pslg0kh9kymfachmz8xgy35n9kj1hpx0ll6wl8iraj76pzbc4dr";
    aarch64-darwin = "04z42ijdimdb7naqfz4ky2syaba1fnsnzwf8w4m133xbp7c0vadw";
  };

  urlMap = {
    i686-linux = "https://github.com/goreleaser/goreleaser/releases/download/v2.6.0/goreleaser_Linux_i386.tar.gz";
    x86_64-linux = "https://github.com/goreleaser/goreleaser/releases/download/v2.6.0/goreleaser_Linux_x86_64.tar.gz";
    armv7l-linux = "https://github.com/goreleaser/goreleaser/releases/download/v2.6.0/goreleaser_Linux_armv7.tar.gz";
    aarch64-linux = "https://github.com/goreleaser/goreleaser/releases/download/v2.6.0/goreleaser_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/goreleaser/goreleaser/releases/download/v2.6.0/goreleaser_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/goreleaser/goreleaser/releases/download/v2.6.0/goreleaser_Darwin_arm64.tar.gz";
  };
in
stdenvNoCC.mkDerivation {
  pname = "goreleaser";
  version = "2.6.0";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./goreleaser $out/bin/goreleaser
    installManPage ./manpages/goreleaser.1.gz
    installShellCompletion ./completions/*
  '';

  system = system;

  meta = {
    description = "Release engineering, simplified";
    homepage = "https://goreleaser.com";
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
