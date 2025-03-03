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
    i686-linux = "1fv31csvz8lykym28vsj763dib4cw70pwv89rid0w56rb45n1xj9";
    x86_64-linux = "1nn2l9qvr40nxdnhlnpl122nqayfgfrm5ykv2ysmk3v29ipwsamn";
    armv7l-linux = "1mihfysf0c9929cvpqhc1vm0yk0p6lxhnm1d9w0kngl6v345pvc6";
    aarch64-linux = "11khnkaxkn8njycip0an6rm44ifw7z2c0k2bs5f5cqa8ivjx5rc4";
    x86_64-darwin = "09sfj6z9wifkz6l0x6x7swbjjy13h0lwr8nx2bl3h6dilwgm8avx";
    aarch64-darwin = "08akdvnxc3qgs06phraczh7rgqzwk0yip3m7s50bh0qrkhqvkhnn";
  };

  urlMap = {
    i686-linux = "https://github.com/charmbracelet/mods/releases/download/v1.7.0/mods_1.7.0_Linux_i386.tar.gz";
    x86_64-linux = "https://github.com/charmbracelet/mods/releases/download/v1.7.0/mods_1.7.0_Linux_x86_64.tar.gz";
    armv7l-linux = "https://github.com/charmbracelet/mods/releases/download/v1.7.0/mods_1.7.0_Linux_arm.tar.gz";
    aarch64-linux = "https://github.com/charmbracelet/mods/releases/download/v1.7.0/mods_1.7.0_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/charmbracelet/mods/releases/download/v1.7.0/mods_1.7.0_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/charmbracelet/mods/releases/download/v1.7.0/mods_1.7.0_Darwin_arm64.tar.gz";
  };
  sourceRootMap = {
    i686-linux = "mods_1.7.0_Linux_i386";
    x86_64-linux = "mods_1.7.0_Linux_x86_64";
    armv7l-linux = "mods_1.7.0_Linux_arm";
    aarch64-linux = "mods_1.7.0_Linux_arm64";
    x86_64-darwin = "mods_1.7.0_Darwin_x86_64";
    aarch64-darwin = "mods_1.7.0_Darwin_arm64";
  };
in
stdenvNoCC.mkDerivation {
  pname = "mods";
  version = "1.7.0";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = sourceRootMap.${system};

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./mods $out/bin/mods
    installManPage ./manpages/mods.1.gz
    installShellCompletion ./completions/*
  '';

  system = system;

  meta = {
    description = "AI on the command line";
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
