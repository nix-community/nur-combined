{ pkgs, stdenv, ... }:

let
  sources = import ./sources.nix;
  srcs = {
    x86_64-linux = pkgs.fetchurl {
      url = sources.amd64_url;
      hash = sources.amd64_hash;
    };
    aarch64-linux = pkgs.fetchurl {
      url = sources.arm64_url;
      hash = sources.arm64_hash;
    };
  };
  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
pkgs.qq.overrideAttrs (final: prev: {
  version = sources.version;
  src = src;
})
