{ pkgs
, stdenv
, lib
, fetchFromGitHub
, buildLinux
, ...
} @ args:

# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/linux-xanmod.nix
let
  version = "5.18.11";
  release = "1";
in
buildLinux {
  inherit stdenv lib version;
  src = fetchFromGitHub {
    owner = "xanmod";
    repo = "linux";
    rev = "${version}-xanmod${release}";
    sha256 = "sha256-UPLwaEWhBu1yriCUJu9L/B8yy+1zxnTQzHaKlT507UY=";
  };
  modDirVersion = "${version}-xanmod${release}-lantian";

  structuredExtraConfig = import ./config.nix args;

  kernelPatches = [
    pkgs.kernelPatches.bridge_stp_helper
    pkgs.kernelPatches.request_key_helper
  ] ++ (builtins.map
    (name: {
      inherit name;
      patch = ./patches + "/${name}";
    })
    (builtins.attrNames (builtins.readDir ./patches)));

  extraMeta.broken = !stdenv.hostPlatform.isx86_64;
}
