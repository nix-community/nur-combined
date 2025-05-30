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
    x86_64-linux = "0w9fa3mvah5w731f5sj4x2bdmbr07bhivk4zw9vcs8ygrcm4hfra";
    aarch64-linux = "0g81i9wpgf4w2jcslks38yp8sabk225hlqaghbbqkh2v1akqcwhl";
    x86_64-darwin = "1fimb3c3knqqnfi5j25vrx9y7mgw0khiyzjyk83lzjy43hx8hqpw";
    aarch64-darwin = "1d9fgvpvzjqy6nfpmagwrcr7fbdnmpgl9457h411nygl6n3z43fk";
  };

  urlMap = {
    x86_64-linux = "https://github.com/goreleaser/nfpm/releases/download/v2.42.1/nfpm_2.42.1_Linux_x86_64.tar.gz";
    aarch64-linux = "https://github.com/goreleaser/nfpm/releases/download/v2.42.1/nfpm_2.42.1_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/goreleaser/nfpm/releases/download/v2.42.1/nfpm_2.42.1_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/goreleaser/nfpm/releases/download/v2.42.1/nfpm_2.42.1_Darwin_arm64.tar.gz";
  };
in
stdenvNoCC.mkDerivation {
  pname = "nfpm";
  version = "2.42.1";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./nfpm $out/bin/nfpm
    installManPage ./manpages/nfpm.1.gz
    installShellCompletion ./completions/*
  '';

  system = system;

  meta = {
    description = "nFPM is a simple, 0-dependencies, deb, rpm, and apk packager.";
    homepage = "https://nfpm.goreleaser.com";
    license = lib.licenses.mit;

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
