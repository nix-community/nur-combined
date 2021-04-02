{ stdenv, lib, fetchurl }:

let

  version = "0.8.11";

in lib.mapAttrs (flavor: attrs:
  stdenv.mkDerivation {
    name = "terraformer-${flavor}";
    inherit version;

    src = fetchurl {
      url = "https://github.com/GoogleCloudPlatform/terraformer/releases/download/${version}/terraformer-${flavor}-linux-amd64";
      inherit (attrs) sha256;
    };
    dontUnpack = true;
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/terraformer-${flavor}
      chmod +x $out/bin/terraformer-${flavor}
    '';
  }) {
    all = { sha256 = lib.fakeSha256; };
    aws = { sha256 = "115g1llp9njgx9fb4ghkq59j81jq0f28hla7151dcvkfg6z13hcp"; };
    azure = { sha256 = lib.fakeSha256; };
    kubernetes = { sha256 = lib.fakeSha256; };
  }
