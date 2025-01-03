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
    x86_64-linux = "0c7l0zj2ww0gdy261nq42ddlriqk18chqzxd15nq7vdbdnm9bkxk";
    aarch64-linux = "1daf29v1j8903g5v38p85mfmc944n5wx6gjpdqn44b4fij1hld8p";
    x86_64-darwin = "0n9x0hz0qil6xgbnxwfxsqlb1vpzl3xswiq69k6lwzb7mahdck2d";
    aarch64-darwin = "0brm2zlb8qnmkk1ms4sp9ayyr5hgpnsijmkswdg445snyfy2n22g";
  };

  urlMap = {
    x86_64-linux = "https://github.com/goreleaser/nfpm/releases/download/v2.41.1/nfpm_2.41.1_Linux_x86_64.tar.gz";
    aarch64-linux = "https://github.com/goreleaser/nfpm/releases/download/v2.41.1/nfpm_2.41.1_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/goreleaser/nfpm/releases/download/v2.41.1/nfpm_2.41.1_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/goreleaser/nfpm/releases/download/v2.41.1/nfpm_2.41.1_Darwin_arm64.tar.gz";
  };
in
stdenvNoCC.mkDerivation {
  pname = "nfpm";
  version = "2.41.1";
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
    description = "nFPM is a simple, 0-dependencies, deb, rpm and apk packager.";
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
