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
    x86_64-linux = "0z139m3cz7anhhc59m9xpmz56kg9xkxdfahfqa8793ycqmp1cla6";
    aarch64-linux = "1ahhdc7d3rn7vqji2462w25cxx9mzxycw2k69lxniirw03w213aw";
    x86_64-darwin = "1fwf62hrffb0qzmmbbd01a7y9z62dkyap6gcp0fbr8w3nifih6lk";
    aarch64-darwin = "0zr45qk0baavvdqdk7vr4fylp0ja7aqdyxq81h90gasafr3x4b0w";
  };

  urlMap = {
    x86_64-linux = "https://github.com/shopware/shopware-cli/releases/download/0.5.18/shopware-cli_Linux_x86_64.tar.gz";
    aarch64-linux = "https://github.com/shopware/shopware-cli/releases/download/0.5.18/shopware-cli_Linux_arm64.tar.gz";
    x86_64-darwin = "https://github.com/shopware/shopware-cli/releases/download/0.5.18/shopware-cli_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/shopware/shopware-cli/releases/download/0.5.18/shopware-cli_Darwin_arm64.tar.gz";
  };
in
stdenvNoCC.mkDerivation {
  pname = "shopware-cli";
  version = "0.5.18";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./shopware-cli $out/bin/shopware-cli
  '';
  postInstall = ''
    installShellCompletion --cmd shopware-cli \
    --bash <($out/bin/shopware-cli completion bash) \
    --zsh <($out/bin/shopware-cli completion zsh) \
    --fish <($out/bin/shopware-cli completion fish)
  '';

  system = system;

  meta = {
    description = "Command line tool for Shopware 6";
    homepage = "https://sw-cli.fos.gg";
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
